import 'package:pizzacorn_community/pizzacorn_community.dart';

class BottomRepost extends ConsumerWidget {
  final bool currentlyReposted;
  final CommunityModel communityModel;
  final PaginationParams<CommunityModel> params;

  BottomRepost({
    super.key,
    required this.communityModel,
    required this.params,
    this.currentlyReposted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Space(SPACE_SMALL),
        ListTile(
          leading: Icon(
            UIconsPro.regularRounded.arrows_retweet,
            color: currentlyReposted ? Colors.green : COLOR_TEXT,
          ),
          title: TextBody(currentlyReposted ? 'Deshacer repost' : 'Repostear'),
          onTap: () {
            goBack(context);
            ref
                .read(communityControllerProvider.notifier)
                .toggleRepost(
                  communityModel: communityModel,
                  params: params,
                  currentlyReposted: currentlyReposted,
                );
          },
        ),
        ListTile(
          leading: Icon(
            UIconsPro.regularRounded.comment_alt,
            color: COLOR_TEXT,
          ),
          title: TextBody('Citar publicación'),
          onTap: () {
            goBack(context);
            goTo(context, CommunityCreatePage(quotePost: getQuoteSource()));
          },
        ),
      ],
    );
  }

  CommunityModel getQuoteSource() {
    if (communityModel.type != CommunityType.repost) return communityModel;
    return CommunityModel(
      id: communityModel.secondaryId,
      userId: communityModel.secondaryUserId,
      userName: communityModel.secondaryUserName,
      userUsername: communityModel.secondaryUserUsername,
      userImage: communityModel.secondaryUserImage,
      text: communityModel.secondaryText,
      mentionIds: communityModel.secondaryMentionIds,
      media: communityModel.secondaryMedia,
      mediaThumbnails: communityModel.secondaryMediaThumbnails,
    );
  }
}
