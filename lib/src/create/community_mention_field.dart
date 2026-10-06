import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityMentionField extends StatefulWidget {
  final CommunityMentionController controller;

  CommunityMentionField({super.key, required this.controller});

  @override
  State<CommunityMentionField> createState() => CommunityMentionFieldState();
}

class CommunityMentionFieldState extends State<CommunityMentionField> {
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: focusNode,
          autofocus: true,
          minLines: 1,
          maxLines: 6,
          maxLength: 250,
          textCapitalization: TextCapitalization.sentences,
          style: styleBody(),
          decoration: InputDecoration(
            hintText: '¿Qué está pasando?',
            hintStyle: styleBody(color: COLOR_SUBTEXT),
            counterStyle: styleSmall(size: 0),
            border: InputBorder.none,
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.controller,
          builder: (context, value, child) {
            final TextRange? range = widget.controller.activeMention;
            if (!focusNode.hasFocus || range == null ||
                !(value.text[range.start] == '#'
                    ? PizzacornCommunityConfig.canSearchEntities
                    : PizzacornCommunityConfig.canSearchUsers) ||
                (value.isComposingRangeValid && !value.composing.isCollapsed)) {
              return SizedBox.shrink();
            }
            final String query = value.text.substring(range.start + 1, value.selection.extentOffset);
            return TextFieldTapRegion(
              child: Focus(
                canRequestFocus: false,
                descendantsAreFocusable: false,
                child: CommunityMentionSheet(
                  query: query,
                  isEntity: value.text[range.start] == '#',
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
