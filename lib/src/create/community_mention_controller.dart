import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityMentionController extends TextEditingController {
  final Map<String, String> selectedMentionIds = {};

  Map<String, String> get mentionIds {
    final Map<String, String> result = {};
    final List<RegExpMatch> matches = mentionExpression.allMatches(text).toList();
    for (int i = 0; i < matches.length; i++) {
      final String token = matches[i].group(0)!;
      final String? id = selectedMentionIds[token];
      if (id != null && id.isNotEmpty) result[token] = id;
    }
    return result;
  }

  static final RegExp usernameExpression = RegExp(
    r'^[\p{L}\p{N}_.+\-]+(?:@[\p{L}\p{N}.\-]+)?$',
    unicode: true,
  );
  static final RegExp mentionExpression = RegExp(
    r'(?<![\w@#.+\-])[@#][\p{L}\p{N}_.+\-]+(?:@[\p{L}\p{N}.\-]+)?',
    unicode: true,
  );

  TextRange? get activeMention {
    if (!selection.isValid || !selection.isCollapsed) return null;
    final int cursor = selection.extentOffset;
    if (cursor > text.length) return null;
    final RegExpMatch? match = RegExp(
      r'(?<![\w@#.+\-])[@#][\p{L}\p{N}_.+\-]*(?:@[\p{L}\p{N}.\-]*)?$',
      unicode: true,
    ).firstMatch(text.substring(0, cursor));
    if (match == null) return null;
    final String suffix = RegExp(r'^[\p{L}\p{N}_.+@\-]*', unicode: true)
        .stringMatch(text.substring(cursor))!;
    return TextRange(start: match.start, end: cursor + suffix.length);
  }

  bool insertMention({
    required CommunityUserModel userModel,
    required TextRange range,
  }) {
    final String username = userModel.username.replaceFirst(RegExp(r'^[@#]'), '');
    if (!usernameExpression.hasMatch(username)) {
      return false;
    }
    final String trigger = text.substring(range.start, range.start + 1);
    final String replacement = '$trigger$username ';
    final String updated = text.replaceRange(range.start, range.end, replacement);
    if (updated.characters.length > 250) return false;
    selectedMentionIds['$trigger$username'] = userModel.id;
    value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: range.start + replacement.length),
    );
    return true;
  }

  static Color mentionColor({required String trigger}) => trigger == '#'
      ? PizzacornCommunityConfig.entitiesMentionColor
      : PizzacornCommunityConfig.usersMentionColor;

  static List<TextSpan> spans({required String text}) {
    final List<RegExpMatch> matches = mentionExpression.allMatches(text).toList();
    final List<TextSpan> spans = [];
    int offset = 0;
    for (int i = 0; i < matches.length; i++) {
      final RegExpMatch match = matches[i];
      spans.add(TextSpan(text: text.substring(offset, match.start)));
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(
          color: mentionColor(trigger: text[match.start]),
          decoration: TextDecoration.underline,
          decorationColor: mentionColor(trigger: text[match.start]),
        ),
      ));
      offset = match.end;
    }
    spans.add(TextSpan(text: text.substring(offset)));
    return spans;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (withComposing && value.isComposingRangeValid && !value.composing.isCollapsed) {
      return super.buildTextSpan(context: context, style: style, withComposing: true);
    }
    return TextSpan(style: style, children: spans(text: text));
  }
}
