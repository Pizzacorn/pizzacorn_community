import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityActionsRow extends ConsumerStatefulWidget {
  final CommunityModel communityModel;
  final PaginationParams<CommunityModel> params;
  final bool showCommentAction;

  CommunityActionsRow({
    super.key,
    required this.communityModel,
    required this.params,
    this.showCommentAction = true,
  });

  @override
  ConsumerState<CommunityActionsRow> createState() => CommunityActionsRowState();
}

class CommunityActionsRowState extends ConsumerState<CommunityActionsRow> {
  bool isLiked = false;
  bool isReposted = false;
  bool isLikeLoading = false;
  int displayedLikesCount = 0;
  int? localLikesCount;

  String get targetId => widget.communityModel.type == CommunityType.repost
      ? widget.communityModel.secondaryId
      : widget.communityModel.id;

  @override
  void initState() {
    super.initState();
    loadInitialUserActions();
  }

  @override
  void didUpdateWidget(covariant CommunityActionsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String oldTargetId = oldWidget.communityModel.type ==
            CommunityType.repost
        ? oldWidget.communityModel.secondaryId
        : oldWidget.communityModel.id;
    if (oldTargetId != targetId) {
      localLikesCount = null;
      loadInitialUserActions();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (targetId.isEmpty) return SizedBox.shrink();
    final AsyncValue<Map<String, int>> counters = ref.watch(
      postCountersFirebaseProvider(targetId),
    );
    final Map<String, int> counts =
        counters.valueOrNull ??
        {
          'likesCount': widget.communityModel.likesCount,
          'commentsCount': widget.communityModel.commentsCount,
          'repostCount': widget.communityModel.repostCount,
        };
    final int likesCount = localLikesCount ?? counts['likesCount'] ?? 0;
    displayedLikesCount = likesCount;

    return Padding(
      padding: EdgeInsets.only(top: SPACE_MEDIUM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommunityActionButton(
            icon: isLiked
                ? UIconsPro.solidRounded.heart
                : UIconsPro.regularRounded.heart,
            label: '$likesCount',
            color: isLiked ? Colors.redAccent : COLOR_SUBTEXT,
            onTap: toggleLike,
          ),
          if (widget.showCommentAction)
            CommunityActionButton(
              icon: UIconsPro.regularRounded.comment,
              label: '${counts['commentsCount'] ?? 0}',
              onTap: openComments,
            ),
          CommunityActionButton(
            icon: UIconsPro.regularRounded.arrows_retweet,
            label: '${counts['repostCount'] ?? 0}',
            color: isReposted ? Colors.green : COLOR_SUBTEXT,
            onTap: () {
              openBottomSheet(
                context,
                BottomRepost(
                  communityModel: widget.communityModel,
                  params: widget.params,
                  currentlyReposted: isReposted,
                ),
                height: 150,
              );
            },
          ),
          Space(SPACE_MEDIUM),
        ],
      ),
    );
  }

  Future<void> openComments() async {
    CommunityModel targetModel = widget.communityModel;
    if (targetModel.type == CommunityType.repost) {
      if (targetModel.secondaryId.isEmpty) return;
      targetModel = await CommunityRepository().getById(
        id: targetModel.secondaryId,
      );
    }
    if (targetModel.id.isNotEmpty && mounted) {
      goTo(context, CommunityDetailsPage(communityModel: targetModel));
    }
  }

  Future<void> toggleLike() async {
    if (isLikeLoading) return;
    final bool previousLiked = isLiked;
    final int previousLikesCount = displayedLikesCount;
    final int nextLikesCount = normalizeCount(
      previousLikesCount + (previousLiked ? -1 : 1),
    );

    setState(() {
      isLiked = !previousLiked;
      localLikesCount = nextLikesCount;
      isLikeLoading = true;
    });

    final bool success = await ref
        .read(communityControllerProvider.notifier)
        .like(
          communityModel: widget.communityModel,
          params: widget.params,
          isCurrentlyLiked: previousLiked,
        );

    if (!mounted) return;
    setState(() {
      isLikeLoading = false;
      if (!success) {
        isLiked = previousLiked;
        localLikesCount = previousLikesCount;
      }
    });
  }

  Future<void> loadInitialUserActions() async {
    if (targetId.isEmpty) return;
    final List<bool> actions = await loadUserActions(targetId: targetId);
    if (!mounted) return;
    setState(() {
      if (!isLikeLoading && localLikesCount == null) {
        isLiked = actions[0];
      }
      isReposted = actions[1];
    });
  }

  int normalizeCount(int value) {
    return value.clamp(0, 999999).toInt();
  }

  Future<List<bool>> loadUserActions({required String targetId}) async {
    final String userId = PizzacornCommunityConfig.currentUser.id;
    if (userId.isEmpty || targetId.isEmpty) return [false, false];
    final FirebaseFirestore database = PizzacornCommunityConfig.database;
    final DocumentReference<Map<String, dynamic>> postReference = database
        .collection(CommunityRepository.collectionName)
        .doc(targetId);
    final List<DocumentSnapshot<Map<String, dynamic>>> snapshots =
        await Future.wait([
          postReference
              .collection(CommunityRepository.subcollectionLikes)
              .doc(userId)
              .get(),
          postReference
              .collection(CommunityRepository.subcollectionReposts)
              .doc(userId)
              .get(),
        ]);
    return [snapshots[0].exists, snapshots[1].exists];
  }
}
