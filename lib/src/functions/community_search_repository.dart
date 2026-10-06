import 'package:pizzacorn_community/pizzacorn_community.dart';

final communitySearchProvider = FutureProvider.autoDispose
    .family<List<CommunityModel>, (String, String)>((ref, searchParams) {
  return CommunitySearchRepository().search(
    query: searchParams.$1,
    filter: searchParams.$2,
  );
});

class CommunitySearchRepository {
  Future<List<CommunityModel>> search({required String query, String filter = ''}) async {
    final String escapedQuery = query.trim().replaceAll('\\', '\\\\').replaceAll('"', '\\"');
    if (escapedQuery.isEmpty) return [];

    // 🔎 Enterprise exige que Search sea la primera etapa de Pipeline.
    Pipeline pipeline = PizzacornCommunityConfig.database
        .pipeline()
        .collection(CommunityRepository.collectionName)
        .search(SearchStage.withQuery('text:"$escapedQuery"'));

    final BooleanExpression visiblePosts = Expression.and(
      Expression.field('hidden').equalValue(false),
      Expression.or(
        Expression.field('type').equalValue(CommunityType.post.name),
        Expression.field('type').equalValue(CommunityType.repost.name),
        Expression.field('type').equalValue(CommunityType.quote.name),
      ),
    );
    pipeline = pipeline
        .where(filter.isEmpty
            ? visiblePosts
            : Expression.and(
                visiblePosts,
                Expression.field('filter').equalValue(filter),
              ))
        .limit(PizzacornCommunityConfig.paginationSize);

    final PipelineSnapshot snapshot = await pipeline.execute();
    final List<CommunityModel> posts = [];
    for (int i = 0; i < snapshot.result.length; i++) {
      final PipelineResult result = snapshot.result[i];
      final Map<String, dynamic>? data = result.data();
      if (data == null) continue;
      final Map<String, dynamic> postData = Map<String, dynamic>.from(data);
      postData['id'] ??= result.document?.id ?? '';
      posts.add(CommunityModel.fromJson(postData));
    }
    return posts;
  }
}
