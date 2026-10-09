import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityPrincipalContent extends StatelessWidget {
  final CommunityModel communityModel;
  final bool noNavigation;
  final bool isSecondary;
  final bool isThird;
  final bool showBorder;
  final bool mentionsEnabled;

  CommunityPrincipalContent({
    super.key,
    required this.communityModel,
    this.noNavigation = false,
    this.isSecondary = false,
    this.isThird = false,
    this.showBorder = false,
    this.mentionsEnabled = true,
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
    final CommunityProfileCallback? onTapUser =
        PizzacornCommunityConfig.onTapUser ??
        PizzacornCommunityConfig.onOpenProfile;
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
    final List<String> mediaThumbnails = isThird
        ? communityModel.thirdMediaThumbnails
        : isSecondary
        ? communityModel.secondaryMediaThumbnails
        : communityModel.mediaThumbnails;
    final String visibleFilter = !isSecondary && !isThird &&
            PizzacornCommunityConfig.showFilterChips &&
            communityModel.filter.trim().isNotEmpty &&
            !PizzacornCommunityConfig.hiddenFilterChips.contains(communityModel.filter)
        ? communityModel.filter
        : '';

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
              onPressed: onTapUser == null || userId.isEmpty
                  ? null
                  : () => onTapUser(context, userId),
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
                  if (visibleFilter.isNotEmpty) ...[
                    Space(SPACE_SMALLEST),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SPACE_SMALL,
                        vertical: SPACE_SMALLEST,
                      ),
                      decoration: BoxDecoration(
                        color: PizzacornCommunityConfig.filterChipColors[visibleFilter] ??
                            COLOR_ACCENT,
                        borderRadius: BorderRadius.circular(RADIUS),
                      ),
                      child: TextCaption(
                        visibleFilter,
                        color: COLOR_TEXT_BUTTONS,
                      ),
                    ),
                  ],
                  if (text.isNotEmpty) ...[
                    Space(SPACE_SMALLEST),
                    CommunityClickableText(
                      text: text,
                      mentionsEnabled: mentionsEnabled,
                      mentionIds: isThird ? communityModel.thirdMentionIds
                          : isSecondary ? communityModel.secondaryMentionIds
                          : communityModel.mentionIds,
                    ),
                  ],
                  if (media.isNotEmpty && !isThird) ...[
                    Space(SPACE_SMALL),
                    buildCommunityImageGrid(context, media: media, mediaThumbnails: mediaThumbnails),
                  ],
                  if (!isSecondary &&
                      !isThird &&
                      (communityModel.type == CommunityType.quote ||
                          communityModel.type == CommunityType.repost))
                    CommunityPrincipalContent(
                      communityModel: communityModel,
                      isSecondary: true,
                      mentionsEnabled: mentionsEnabled,
                      showBorder: showBorder,
                    ),
                  if (isSecondary && communityModel.thirdId.isNotEmpty)
                    CommunityPrincipalContent(
                      communityModel: communityModel,
                      isThird: true,
                      mentionsEnabled: mentionsEnabled,
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
  final Map<String, String> mentionIds;
  final bool mentionsEnabled;

  CommunityClickableText({super.key, required this.text, this.mentionIds = const {}, this.mentionsEnabled = true});

  @override
  State<CommunityClickableText> createState() => CommunityClickableTextState();
}

class CommunityClickableTextState extends State<CommunityClickableText> {
  final List<TapGestureRecognizer> recognizers = [];

  List<TextSpan> mentionSpans({required String text}) {
    final List<TextSpan> spans = CommunityMentionController.spans(text: text);
    for (int i = 0; i < spans.length; i++) {
      final TextSpan span = spans[i];
      final String token = span.text ?? '';
      final String? id = widget.mentionIds[token];
      if (!widget.mentionsEnabled || id == null || id.isEmpty || span.style == null) continue;
      final CommunityProfileCallback? callback = token.startsWith('#')
          ? PizzacornCommunityConfig.onEntitieMentionPressed ??
              PizzacornCommunityConfig.onTapEntityMention
          : PizzacornCommunityConfig.onUserMentionPressed ??
              PizzacornCommunityConfig.onTapUserMention;
      if (callback == null) continue;
      final TapGestureRecognizer recognizer = TapGestureRecognizer()
        ..onTap = () { callback(context, id); };
      recognizers.add(recognizer);
      spans[i] = TextSpan(text: token, style: span.style, recognizer: recognizer);
    }
    return spans;
  }

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
    final List<RegExpMatch> mentions = CommunityMentionController.mentionExpression
        .allMatches(widget.text).toList();

    for (int i = 0; i < matches.length; i++) {
      final RegExpMatch match = matches[i];
      bool overlapsMention = false;
      for (int j = 0; j < mentions.length; j++) {
        if (match.start < mentions[j].end && match.end > mentions[j].start) {
          overlapsMention = true;
          break;
        }
      }
      if (overlapsMention) continue;
      if (match.start > lastMatchEnd) {
        spans.addAll(mentionSpans(
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
      spans.addAll(mentionSpans(
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
