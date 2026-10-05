import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityPrincipalContent extends StatelessWidget {
  final CommunityModel communityModel;
  final bool noNavigation;
  final bool isSecondary;
  final bool isThird;
  final bool showBorder;

  CommunityPrincipalContent({
    super.key,
    required this.communityModel,
    this.noNavigation = false,
    this.isSecondary = false,
    this.isThird = false,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final String userImage = isThird
        ? communityModel.thirdUserImage
        : isSecondary
        ? communityModel.secondaryUserImage
        : communityModel.userImage;
    final String userName = isThird
        ? communityModel.thirdUserName
        : isSecondary
        ? communityModel.secondaryUserName
        : communityModel.userName;
    final String userUsername = isThird
        ? communityModel.thirdUserUsername
        : isSecondary
        ? communityModel.secondaryUserUsername
        : communityModel.userUsername;
    final String userId = isThird
        ? communityModel.thirdUserId
        : isSecondary
        ? communityModel.secondaryUserId
        : communityModel.userId;
    final String text = isThird
        ? communityModel.thirdText
        : isSecondary
        ? communityModel.secondaryText
        : communityModel.text;
    final List<String> media = isThird
        ? communityModel.thirdMedia
        : isSecondary
        ? communityModel.secondaryMedia
        : communityModel.media;

    return InkWell(
      onTap: () => openDetails(context),
      borderRadius: BorderRadius.circular(RADIUS),
      child: Container(
        margin: (isSecondary || isThird) && showBorder
            ? EdgeInsets.only(top: SPACE_SMALL)
            : null,
        padding: PADDING_ALL_SMALL,
        decoration: (isSecondary || isThird) && showBorder
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(RADIUS),
                border: Border.all(color: COLOR_BORDER, width: 0.8),
              )
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileImageCustom(
              imageUrl: userImage,
              size: 40,
              singleBorder: true,
              innerBorderWidth: 0,
              outerBorderWidth: 0,
              onPressed: () {
                PizzacornCommunityConfig.onOpenProfile?.call(context, userId);
              },
            ),
            Space(SPACE_SMALL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TextBody(
                          userName.isEmpty ? 'Usuario' : userName,
                          fontWeight: FontWeight.bold,
                          maxlines: 1,
                        ),
                      ),
                      if (userUsername.isNotEmpty) ...[
                        Space(SPACE_SMALLEST),
                        Flexible(
                          child: TextCaption('@$userUsername', maxlines: 1),
                        ),
                      ],
                      if (!isThird) ...[
                        Space(SPACE_SMALLEST),
                        TextCaption(
                          '· ${formatCommunityTimeAgo(communityModel.createdAt)}',
                        ),
                      ],
                    ],
                  ),
                  if (text.isNotEmpty) ...[
                    Space(SPACE_SMALLEST),
                    CommunityClickableText(text: text),
                  ],
                  if (media.isNotEmpty && !isThird) ...[
                    Space(SPACE_SMALL),
                    buildCommunityImageGrid(context, media: media),
                  ],
                  if (!isSecondary &&
                      !isThird &&
                      (communityModel.type == CommunityType.quote ||
                          communityModel.type == CommunityType.repost))
                    CommunityPrincipalContent(
                      communityModel: communityModel,
                      isSecondary: true,
                      showBorder: showBorder,
                    ),
                  if (isSecondary && communityModel.thirdId.isNotEmpty)
                    CommunityPrincipalContent(
                      communityModel: communityModel,
                      isThird: true,
                      showBorder: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openDetails(BuildContext context) async {
    if (noNavigation || communityModel.type == CommunityType.comment) return;
    final String targetId = isThird
        ? communityModel.thirdId
        : isSecondary
        ? communityModel.secondaryId
        : communityModel.id;
    if (targetId.isEmpty) return;

    final CommunityModel targetModel = isSecondary || isThird
        ? await CommunityRepository().getById(id: targetId)
        : communityModel;
    if (targetModel.id.isNotEmpty && context.mounted) {
      goTo(context, CommunityDetailsPage(communityModel: targetModel));
    }
  }
}

class CommunityClickableText extends StatefulWidget {
  final String text;

  CommunityClickableText({super.key, required this.text});

  @override
  State<CommunityClickableText> createState() => CommunityClickableTextState();
}

class CommunityClickableTextState extends State<CommunityClickableText> {
  final List<TapGestureRecognizer> recognizers = [];

  @override
  void dispose() {
    clearRecognizers();
    super.dispose();
  }

  void clearRecognizers() {
    for (int i = 0; i < recognizers.length; i++) {
      recognizers[i].dispose();
    }
    recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    clearRecognizers();
    final RegExp urlExpression = RegExp(
      r'((https?:\/\/)|(www\.))?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );
    final List<TextSpan> spans = [];
    final List<RegExpMatch> matches = urlExpression
        .allMatches(widget.text)
        .toList();
    int lastMatchEnd = 0;

    for (int i = 0; i < matches.length; i++) {
      final RegExpMatch match = matches[i];
      if (match.start > lastMatchEnd) {
        spans.addAll(CommunityMentionController.spans(
          text: widget.text.substring(lastMatchEnd, match.start),
        ));
      }
      final String url = widget.text.substring(match.start, match.end);
      final TapGestureRecognizer recognizer = TapGestureRecognizer()
        ..onTap = () => openUrl(url);
      recognizers.add(recognizer);
      spans.add(
        TextSpan(
          text: url,
          style: styleBody(color: Colors.blue, fontWeight: FontWeight.bold),
          recognizer: recognizer,
        ),
      );
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < widget.text.length) {
      spans.addAll(CommunityMentionController.spans(
        text: widget.text.substring(lastMatchEnd),
      ));
    }
    return RichText(
      text: TextSpan(style: styleBody(), children: spans),
    );
  }

  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
