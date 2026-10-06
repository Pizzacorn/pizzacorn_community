import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityWidget extends StatelessWidget {
  final CommunityModel communityModel;
  final VoidCallback onDelete;
  final PaginationParams<CommunityModel> params;
  final bool noNavigation;
  final bool noBorderRadius;
  final bool isQuotePreview;

  CommunityWidget({
    super.key,
    required this.communityModel,
    required this.onDelete,
    required this.params,
    this.noNavigation = false,
    this.noBorderRadius = false,
    this.isQuotePreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRepost = communityModel.type == CommunityType.repost;
    final bool isComment = communityModel.type == CommunityType.comment;
    final CommunityUserModel currentUser = PizzacornCommunityConfig.currentUser;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: SPACE_SMALL),
        decoration: BoxDecoration(
          color: PizzacornCommunityConfig.backgroundColor,
          borderRadius: noBorderRadius ? null : BorderRadius.circular(RADIUS),
          border: Border(bottom: BorderSide(color: COLOR_BORDER, width: 0.5)),
        ),
        child: Column(
          children: [
            if (isRepost)
              Padding(
                padding: EdgeInsets.only(left: 58, top: SPACE_SMALLEST),
                child: Row(
                  children: [
                    Icon(
                      UIconsPro.regularRounded.arrows_retweet,
                      size: 14,
                      color: Colors.green,
                    ),
                    Space(SPACE_SMALLEST),
                    TextCaption(
                      '${communityModel.userName} ha compartido',
                      fontWeight: FontWeight.bold,
                      color: COLOR_TEXT,
                    ),
                  ],
                ),
              ),
            Stack(
              children: [
                CommunityPrincipalContent(
                  communityModel: communityModel,
                  noNavigation: noNavigation,
                  mentionsEnabled: !isQuotePreview,
                  isSecondary: isRepost,
                  showBorder: !isRepost,
                ),
                if (!isQuotePreview)
                  Positioned(
                    right: 4,
                    top: 0,
                    child: MoreMenuButton(
                      iconSize: 14,
                      onDelete: communityModel.userId == currentUser.id
                          ? onDelete
                          : null,
                      onReport: communityModel.userId != currentUser.id
                          ? () {
                              openBottomSheet(
                                context,
                                ReportCommunityBottom(
                                  communityModel: communityModel,
                                ),
                                height: 600,
                              );
                            }
                          : null,
                    ),
                  ),
              ],
            ),
            if (!isQuotePreview && !isComment)
              Padding(
                padding: EdgeInsets.only(left: 55),
                child: CommunityActionsRow(
                  communityModel: communityModel,
                  params: params,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
