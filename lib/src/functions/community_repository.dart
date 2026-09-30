import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityRepository {
  static const String collectionName = 'Community';
  static const String subcollectionLikes = 'Likes';
  static const String subcollectionReposts = 'Reposts';

  FirebaseFirestore get database => PizzacornCommunityConfig.database;
  CommunityUserModel get currentUser => PizzacornCommunityConfig.currentUser;

  Future<CommunityModel> getById({required String id}) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await database
        .collection(collectionName)
        .doc(id)
        .get();
    if (!snapshot.exists || snapshot.data() == null) return CommunityModel();
    return CommunityModel.fromJson(snapshot.data()!);
  }

  Future<CommunityModel> save({
    required CommunityModel communityModel,
    bool isComment = false,
    bool isRepost = false,
    bool isQuote = false,
  }) async {
    ensureAuthenticated();
    final WriteBatch batch = database.batch();
    final DocumentReference<Map<String, dynamic>> reference = database
        .collection(collectionName)
        .doc();
    final CommunityModel readyToSave = communityModel.copyWith(
      id: reference.id,
      userId: currentUser.id,
      userName: currentUser.name,
      userUsername: currentUser.username,
      userImage: currentUser.image,
    );

    if (isRepost || isQuote) {
      applyRepostLogic(batch: batch, parentId: readyToSave.secondaryId);
    } else if (isComment) {
      batch.update(
        database.collection(collectionName).doc(readyToSave.secondaryId),
        {
          'commentsCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }

    batch.set(reference, readyToSave.toJsonCreate());
    await batch.commit();
    await PizzacornCommunityConfig.onSendNotification?.call(
      CommunityNotificationType.post,
      readyToSave,
    );
    return readyToSave;
  }

  void applyRepostLogic({required WriteBatch batch, required String parentId}) {
    final DocumentReference<Map<String, dynamic>> trackReference = database
        .collection(collectionName)
        .doc(parentId)
        .collection(subcollectionReposts)
        .doc(currentUser.id);
    batch.set(trackReference, {
      'userId': currentUser.id,
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'repost',
    });
    batch.update(database.collection(collectionName).doc(parentId), {
      'repostCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> findRepostId({
    required String originalId,
    required String userId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await database
        .collection(collectionName)
        .where('type', isEqualTo: CommunityType.repost.name)
        .where('userId', isEqualTo: userId)
        .where('secondaryId', isEqualTo: originalId)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty ? '' : snapshot.docs.first.id;
  }

  Future<bool> delete({required String postId}) async {
    ensureAuthenticated();
    final DocumentReference<Map<String, dynamic>> documentReference = database
        .collection(collectionName)
        .doc(postId);
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await documentReference.get();
    if (!snapshot.exists || snapshot.data() == null) return false;

    final CommunityModel communityModel = CommunityModel.fromJson(
      snapshot.data()!,
    );
    final WriteBatch batch = database.batch();
    batch.delete(documentReference);

    if (communityModel.secondaryId.isNotEmpty) {
      batch.delete(
        database
            .collection(collectionName)
            .doc(communityModel.secondaryId)
            .collection(subcollectionReposts)
            .doc(communityModel.userId),
      );
      batch.update(
        database.collection(collectionName).doc(communityModel.secondaryId),
        {
          'repostCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }
    await batch.commit();
    return true;
  }

  Future<bool> softDelete({required String postId}) async {
    ensureAuthenticated();
    await database.collection(collectionName).doc(postId).update({
      'hidden': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  Future<bool> updateLike({
    required String postId,
    required CommunityModel communityModel,
  }) async {
    ensureAuthenticated();
    final DocumentReference<Map<String, dynamic>> postReference = database
        .collection(collectionName)
        .doc(postId);
    final DocumentReference<Map<String, dynamic>> likeReference = postReference
        .collection(subcollectionLikes)
        .doc(currentUser.id);
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await likeReference
        .get();
    final WriteBatch batch = database.batch();

    if (snapshot.exists) {
      batch.delete(likeReference);
      batch.update(postReference, {'likesCount': FieldValue.increment(-1)});
    } else {
      batch.set(likeReference, {
        'userId': currentUser.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.update(postReference, {'likesCount': FieldValue.increment(1)});
    }
    await batch.commit();

    if (!snapshot.exists) {
      await PizzacornCommunityConfig.onSendNotification?.call(
        CommunityNotificationType.like,
        communityModel,
      );
    }
    return !snapshot.exists;
  }

  Future<void> report({
    required CommunityModel communityModel,
    required String reason,
  }) async {
    ensureAuthenticated();
    final DocumentReference<Map<String, dynamic>> reference = database
        .collection('Reports')
        .doc();
    await reference.set({
      'id': reference.id,
      'userId': currentUser.id,
      'userName': currentUser.name,
      'userImage': currentUser.image,
      'post': communityModel.toJson(),
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await PizzacornCommunityConfig.onReport?.call(communityModel, reason);
  }

  void ensureAuthenticated() {
    if (currentUser.id.isEmpty) {
      throw StateError(
        'Configura un usuario con id antes de realizar acciones en CommunityPage.',
      );
    }
  }
}
