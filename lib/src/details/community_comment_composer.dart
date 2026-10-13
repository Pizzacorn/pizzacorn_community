import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityCommentComposer extends StatefulWidget {
  final CommunityMentionController controller;
  final VoidCallback onPickImages;
  final VoidCallback onSend;

  CommunityCommentComposer({
    super.key,
    required this.controller,
    required this.onPickImages,
    required this.onSend,
  });

  @override
  State<CommunityCommentComposer> createState() => CommunityCommentComposerState();
}

class CommunityCommentComposerState extends State<CommunityCommentComposer> {
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChanged);
  }

  void onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    focusNode.removeListener(onFocusChanged);
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onPickImages,
              icon: Icon(UIconsPro.regularRounded.picture, color: COLOR_ACCENT, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: focusNode,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 4,
                maxLength: 250,
                style: styleBody(),
                decoration: InputDecoration(
                  hintText: 'Añade una respuesta',
                  hintStyle: styleBody(color: COLOR_SUBTEXT),
                  counterText: '',
                  border: OutlineInputBorder(borderSide: BorderSide(color: COLOR_BORDER)),
                ),
              ),
            ),
            IconButton(
              onPressed: widget.onSend,
              icon: Icon(UIconsPro.regularRounded.paper_plane_top, color: COLOR_ACCENT, size: 20),
            ),
          ],
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.controller,
          builder: (context, value, child) {
            final TextRange? range = widget.controller.activeMention;
            if (!focusNode.hasFocus || range == null ||
                (value.isComposingRangeValid && !value.composing.isCollapsed)) {
              return SizedBox.shrink();
            }
            final bool isEntity = value.text[range.start] == '#';
            if (isEntity
                ? !PizzacornCommunityConfig.canSearchEntities
                : !PizzacornCommunityConfig.canSearchUsers) {
              return SizedBox.shrink();
            }
            return TextFieldTapRegion(
              child: Focus(
                canRequestFocus: false,
                descendantsAreFocusable: false,
                child: CommunityMentionSheet(
                  query: value.text.substring(range.start + 1, value.selection.extentOffset),
                  isEntity: isEntity,
                  onSelected: ({required CommunityUserModel userModel}) {
                    final TextRange? currentRange = widget.controller.activeMention;
                    if (currentRange == null) return false;
                    final bool inserted = widget.controller.insertMention(
                      userModel: userModel,
                      range: currentRange,
                    );
                    focusNode.requestFocus();
                    return inserted;
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
