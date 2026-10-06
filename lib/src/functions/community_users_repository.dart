import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityUsersRepository {
  Future<List<CommunityUserModel>> search({required String query, bool isEntity = false}) async {
    final CommunitySearchUsersCallback? callback = isEntity ? PizzacornCommunityConfig.onSearchEntities : PizzacornCommunityConfig.onSearchUsers;
    if (callback != null) return callback(query: query.trim());
    final String? collection = isEntity ? PizzacornCommunityConfig.entitiesCollection : PizzacornCommunityConfig.usersCollection;
    final String? nicknameField = isEntity ? PizzacornCommunityConfig.entitiesNicknameField : PizzacornCommunityConfig.usersNicknameField;
    if (collection == null || nicknameField == null) return [];

    final String prefix = query.trim();
    if ((isEntity ? PizzacornCommunityConfig.entitiesSearchMode : PizzacornCommunityConfig.usersSearchMode) == CommunityUsersSearchMode.enterprise) {
      return searchEnterprise(collection: collection, nicknameField: nicknameField, query: prefix, isEntity: isEntity);
    }
    Query<Map<String, dynamic>> usersQuery = PizzacornCommunityConfig.database
        .collection(collection)
        .orderBy(nicknameField);
    if (prefix.isNotEmpty) {
      usersQuery = usersQuery.startAt([prefix]).endAt(['$prefix\uf8ff']);
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot = await usersQuery.limit(20).get();
    final List<CommunityUserModel> users = [];
    for (int i = 0; i < snapshot.docs.length; i++) {
      final QueryDocumentSnapshot<Map<String, dynamic>> document = snapshot.docs[i];
      final String nickname = readString(document: document, field: nicknameField);
      if (nickname.isEmpty) continue;
      final String name = readString(
        document: document,
        field: isEntity ? PizzacornCommunityConfig.entitiesNameField : PizzacornCommunityConfig.usersNameField,
      );
      users.add(CommunityUserModel(
        id: document.id,
        username: nickname,
        name: name.isEmpty ? nickname : name,
        image: readString(
          document: document,
          field: isEntity ? PizzacornCommunityConfig.entitiesImageField : PizzacornCommunityConfig.usersImageField,
        ),
      ));
    }
    return users;
  }

  Future<List<CommunityUserModel>> searchEnterprise({
    required String collection,
    required String nicknameField,
    required String query,
    bool isEntity = false,
  }) async {
    Pipeline pipeline = PizzacornCommunityConfig.database.pipeline().collection(collection);
    if (query.isNotEmpty) {
      // 🔎 Search debe ser la primera etapa después de la colección.
      pipeline = pipeline.search(SearchStage.withQuery(
        buildEnterpriseQuery(nicknameField: nicknameField, query: query),
        limit: 20,
      ));
    } else {
      pipeline = pipeline.sort(Expression.field(nicknameField).ascending()).limit(20);
    }
    final PipelineSnapshot snapshot = await pipeline.execute();
    final List<CommunityUserModel> users = [];
    for (int i = 0; i < snapshot.result.length; i++) {
      final PipelineResult result = snapshot.result[i];
      final Map<String, dynamic>? data = result.data();
      if (data == null || result.document == null) continue;
      final String nickname = readDataString(data: data, field: nicknameField);
      if (nickname.isEmpty) continue;
      final String name = readDataString(data: data, field: isEntity ? PizzacornCommunityConfig.entitiesNameField : PizzacornCommunityConfig.usersNameField);
      users.add(CommunityUserModel(
        id: result.document!.id,
        username: nickname,
        name: name.isEmpty ? nickname : name,
        image: readDataString(data: data, field: isEntity ? PizzacornCommunityConfig.entitiesImageField : PizzacornCommunityConfig.usersImageField),
      ));
    }
    return users;
  }

  String buildEnterpriseQuery({required String nicknameField, required String query}) {
    if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*)*$').hasMatch(nicknameField)) {
      throw ArgumentError('El campo de nickname Enterprise debe ser una ruta simple separada por puntos.');
    }
    final String escaped = query.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
    return '$nicknameField:"$escaped"';
  }

  String readDataString({required Map<String, dynamic> data, required String? field}) {
    if (field == null || field.isEmpty) return '';
    final List<String> parts = field.split('.');
    Object? value = data;
    for (int i = 0; i < parts.length; i++) {
      if (value is! Map) return '';
      value = value[parts[i]];
    }
    return value is String ? value : '';
  }

  String readString({
    required QueryDocumentSnapshot<Map<String, dynamic>> document,
    required String? field,
  }) {
    if (field == null || field.isEmpty) return '';
    try {
      final Object? value = document.get(field);
      return value is String ? value : '';
    } on StateError {
      return '';
    }
  }
}
