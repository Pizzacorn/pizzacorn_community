import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityAttachedCard extends StatelessWidget {
  final CommunityAttachmentModel attachmentModel;
  final VoidCallback? onRemove;

  CommunityAttachedCard({
    super.key,
    required this.attachmentModel,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEntity = attachmentModel.type == 'entity';
    final Color buttonColor = isEntity
        ? PizzacornCommunityConfig.entityAttachmentButtonColor ?? COLOR_ACCENT
        : PizzacornCommunityConfig.profileAttachmentButtonColor ?? COLOR_ACCENT;
    final Color buttonTextColor = isEntity
        ? PizzacornCommunityConfig.entityAttachmentButtonTextColor ?? COLOR_TEXT_BUTTONS
        : PizzacornCommunityConfig.profileAttachmentButtonTextColor ?? COLOR_TEXT_BUTTONS;
    final Color borderColor = isEntity
        ? PizzacornCommunityConfig.entityAttachmentButtonBorderColor ?? buttonColor
        : PizzacornCommunityConfig.profileAttachmentButtonBorderColor ?? buttonColor;
    final double borderWidth = isEntity
        ? PizzacornCommunityConfig.entityAttachmentButtonBorderWidth
        : PizzacornCommunityConfig.profileAttachmentButtonBorderWidth;
    final String buttonText = isEntity
        ? PizzacornCommunityConfig.viewEntityAttachmentText
        : PizzacornCommunityConfig.viewProfileAttachmentText;
    final CommunityAttachmentPressedCallback? callback = isEntity
        ? PizzacornCommunityConfig.onEntityAttachmentPressed
        : PizzacornCommunityConfig.onProfileAttachmentPressed;
    final CommunityProfileCallback? fallback = isEntity
        ? PizzacornCommunityConfig.onEntitieMentionPressed ??
            PizzacornCommunityConfig.onTapEntityMention
        : PizzacornCommunityConfig.onUserMentionPressed ??
            PizzacornCommunityConfig.onTapUser ??
            PizzacornCommunityConfig.onOpenProfile;

    return Container(
      width: double.infinity,
      padding: PADDING_ALL,
      decoration: BoxDecoration(
        color: PizzacornCommunityConfig.backgroundSecondaryColor,
        borderRadius: BorderRadius.circular(RADIUS),
        border: Border.all(color: COLOR_BORDER),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (attachmentModel.image.isNotEmpty) ...[
              ProfileImageCustom(imageUrl: attachmentModel.image, size: 48),
              Space(SPACE_SMALL),
            ],
            Expanded(child: TextTitle(attachmentModel.title)),
            if (onRemove != null)
              IconButton(onPressed: onRemove, icon: Icon(Icons.close)),
          ]),
          if (attachmentModel.body.isNotEmpty) ...[
            Space(SPACE_SMALL),
            TextBody(attachmentModel.body),
          ],
          if (attachmentModel.chip.isNotEmpty) ...[
            Space(SPACE_SMALL),
            Container(
              padding: EdgeInsets.symmetric(horizontal: SPACE_SMALL, vertical: SPACE_SMALLEST),
              decoration: BoxDecoration(
                color: COLOR_ACCENT.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(RADIUS),
              ),
              child: TextCaption(attachmentModel.chip, color: COLOR_ACCENT),
            ),
          ],
          Space(SPACE_MEDIUM),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: buttonTextColor,
              side: BorderSide(color: borderColor, width: borderWidth),
            ),
            onPressed: callback == null && fallback == null ? null : () {
              if (callback != null) {
                callback(context, attachmentModel);
              } else {
                fallback?.call(context, attachmentModel.targetId);
              }
            },
            child: TextButtonCustom(buttonText, color: buttonTextColor),
          ),
        ],
      ),
    );
  }
}
