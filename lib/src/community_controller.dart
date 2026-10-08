import 'package:pizzacorn_community/pizzacorn_community.dart';

PaginationParams<CommunityModel> get communityParams => communityParamsForFilter();

PaginationParams<CommunityModel> communityParamsForFilter({String filter = ''}) {
  final CommunityUserModel currentUser = PizzacornCommunityConfig.currentUser;
  return PaginationParams<CommunityModel>(
    collection: CommunityRepository.collectionName,
    identifier: filter.isEmpty
        ? 'community_${currentUser.id}'
        : 'community_${currentUser.id}_$filter',
    databaseName: PizzacornCommunityConfig.databaseName,
    limit: PizzacornCommunityConfig.paginationSize,
    fromJson: (data) => CommunityModel.fromJson(data),
    itemFilter: (communityModel) =>
        !PizzacornCommunityConfig.isPostBlocked(communityModel),
    query: (query) {
      final filteredQuery = filter.isEmpty
          ? query
          : query.where('filter', isEqualTo: filter);
      return filteredQuery
        .where('hidden', isEqualTo: false)
        .where(
          'type',
          whereIn: [
            CommunityType.post.name,
            CommunityType.repost.name,
            CommunityType.quote.name,
          ],
        )
        .orderBy('createdAt', descending: true);
    },
  );
}

final postCountersFirebaseProvider =
    FutureProvider.family<Map<String, int>, String>((ref, targetId) async {
      if (targetId.isEmpty) {
        return {'likesCount': 0, 'repostCount': 0, 'commentsCount': 0};
      }
      final CommunityModel original = await CommunityRepository().getById(
        id: targetId,
      );
      return {
        'likesCount': original.likesCount,
        'repostCount': original.repostCount,
        'commentsCount': original.commentsCount,
      };
    });

class CommunityState {
  final bool isLoading;
  final String isError;
  final String selectedFilter;
  final String searchQuery;

  CommunityState({this.isLoading = false, this.isError = '', this.selectedFilter = '', this.searchQuery = ''});

  CommunityState copyWith({bool? isLoading, String? isError, String? selectedFilter, String? searchQuery}) {
    return CommunityState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final communityControllerProvider =
    NotifierProvider.autoDispose<CommunityController, CommunityState>(
      CommunityController.new,
    );

class CommunityController extends AutoDisposeNotifier<CommunityState> {
  final CommunityRepository repository = CommunityRepository();
  Timer? searchDebounce;

  @override
  CommunityState build() {
    ref.onDispose(() => searchDebounce?.cancel());
    return CommunityState();
  }

  void search({required String query}) {
    searchDebounce?.cancel();
    final String cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      state = state.copyWith(searchQuery: '');
      return;
    }
    searchDebounce = Timer(Duration(milliseconds: 300), () {
      state = state.copyWith(searchQuery: cleanQuery);
    });
  }

  void selectFilter({required String filter}) {
    state = state.copyWith(selectedFilter: filter);
  }

  Future<bool> like({
    required CommunityModel communityModel,
    required PaginationParams<CommunityModel> params,
    required bool isCurrentlyLiked,
  }) async {
    final String targetId = communityModel.type == CommunityType.repost
        ? communityModel.secondaryId
        : communityModel.id;
    if (targetId.isEmpty) return false;
    final bool willLike = !isCurrentlyLiked;
    updateCountGlobal(
      targetId: targetId,
      likesDelta: willLike ? 1 : -1,
      params: params,
    );

    try {
      await repository.updateLike(
        postId: targetId,
        communityModel: communityModel,
      );
      ref.invalidate(postCountersFirebaseProvider(targetId));
      return true;
    } catch (error) {
      updateCountGlobal(
        targetId: targetId,
        likesDelta: willLike ? -1 : 1,
        params: params,
      );
      state = state.copyWith(isError: error.toString());
      return false;
    }
  }

  Future<void> toggleRepost({
    required CommunityModel communityModel,
    required PaginationParams<CommunityModel> params,
    required bool currentlyReposted,
  }) async {
    final String originalPostId = communityModel.type == CommunityType.repost
        ? communityModel.secondaryId
        : communityModel.id;
    if (originalPostId.isEmpty) return;
    final bool willRepost = !currentlyReposted;
    updateCountGlobal(
      targetId: originalPostId,
      repostDelta: willRepost ? 1 : -1,
      params: params,
    );

    try {
      if (willRepost) {
        final CommunityModel repostModel = CommunityModel(
          type: CommunityType.repost,
          filter: communityModel.filter,
          secondaryId: communityModel.type == CommunityType.repost
              ? communityModel.secondaryId
              : communityModel.id,
          secondaryUserId: communityModel.type == CommunityType.repost
              ? communityModel.secondaryUserId
              : communityModel.userId,
          secondaryUserName: communityModel.type == CommunityType.repost
              ? communityModel.secondaryUserName
              : communityModel.userName,
          secondaryUserUsername: communityModel.type == CommunityType.repost
              ? communityModel.secondaryUserUsername
              : communityModel.userUsername,
          secondaryUserImage: communityModel.type == CommunityType.repost
              ? communityModel.secondaryUserImage
              : communityModel.userImage,
          secondaryText: communityModel.type == CommunityType.repost
              ? communityModel.secondaryText
              : communityModel.text,
          secondaryMentionIds: communityModel.type == CommunityType.repost
              ? communityModel.secondaryMentionIds
              : communityModel.mentionIds,
          secondaryMedia: communityModel.type == CommunityType.repost
              ? communityModel.secondaryMedia
              : communityModel.media,
          secondaryType: communityModel.type.name,
          thirdId: communityModel.thirdId,
          thirdUserId: communityModel.thirdUserId,
          thirdUserName: communityModel.thirdUserName,
          thirdUserUsername: communityModel.thirdUserUsername,
          thirdUserImage: communityModel.thirdUserImage,
          thirdText: communityModel.thirdText,
          thirdMentionIds: communityModel.thirdMentionIds,
          thirdMedia: communityModel.thirdMedia,
        );
        final CommunityModel saved = await repository.save(
          communityModel: repostModel,
          isRepost: true,
        );
        updateLocally(communityModel: saved, params: params, isAddition: true);
      } else {
        final String repostId = communityModel.type == CommunityType.repost
            ? communityModel.id
            : await repository.findRepostId(
                originalId: communityModel.id,
                userId: PizzacornCommunityConfig.currentUser.id,
              );
        if (repostId.isNotEmpty && await repository.delete(postId: repostId)) {
          updateLocally(
            communityModel: CommunityModel(id: repostId),
            params: params,
            isRemoval: true,
          );
        }
      }
      ref.invalidate(postCountersFirebaseProvider(originalPostId));
    } catch (error) {
      updateCountGlobal(
        targetId: originalPostId,
        repostDelta: willRepost ? -1 : 1,
        params: params,
      );
      state = state.copyWith(isError: error.toString());
    }
  }

  Future<void> delete({
    required CommunityModel communityModel,
    required PaginationParams<CommunityModel> params,
  }) async {
    try {
      if (await repository.softDelete(postId: communityModel.id)) {
        updateLocally(
          communityModel: communityModel,
          params: params,
          isRemoval: true,
        );
      }
    } catch (error) {
      state = state.copyWith(isError: error.toString());
    }
  }

  void updateLocally({
    required CommunityModel communityModel,
    required PaginationParams<CommunityModel> params,
    bool isAddition = false,
    bool isRemoval = false,
  }) {
    final provider = paginationProvider(params);
    final currentState = ref.read(provider);
    final List<CommunityModel> items = List.from(currentState.items);

    if (isRemoval) {
      for (int i = items.length - 1; i >= 0; i--) {
        if (items[i].id == communityModel.id) {
          items.removeAt(i);
        }
      }
    } else if (isAddition) {
      items.insert(0, communityModel);
    } else {
      for (int i = 0; i < items.length; i++) {
        if (items[i].id == communityModel.id ||
            items[i].secondaryId == communityModel.id) {
          items[i] = items[i].copyWith(
            likesCount: communityModel.likesCount,
            commentsCount: communityModel.commentsCount,
            repostCount: communityModel.repostCount,
          );
        }
      }
    }
    ref.read(provider.notifier).state = currentState.copyWith(items: items);
    if ((isAddition || isRemoval) && state.searchQuery.isNotEmpty) {
      ref.invalidate(communitySearchProvider((state.searchQuery, state.selectedFilter)));
    }
  }

  void updateCountGlobal({
    required String targetId,
    required PaginationParams<CommunityModel> params,
    int likesDelta = 0,
    int repostDelta = 0,
    int commentDelta = 0,
  }) {
    final provider = paginationProvider(params);
    final currentState = ref.read(provider);
    final List<CommunityModel> items = List.from(currentState.items);

    for (int i = 0; i < items.length; i++) {
      if (items[i].id == targetId || items[i].secondaryId == targetId) {
        items[i] = items[i].copyWith(
          likesCount: (items[i].likesCount + likesDelta).clamp(0, 999999),
          repostCount: (items[i].repostCount + repostDelta).clamp(0, 999999),
          commentsCount: (items[i].commentsCount + commentDelta).clamp(
            0,
            999999,
          ),
        );
      }
    }
    ref.read(provider.notifier).state = currentState.copyWith(items: items);
  }
}
