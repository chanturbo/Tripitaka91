import 'package:flutter/material.dart';

TextSpan txtSpanHighlight(List<String> wordsToHighlight, String fullText,
    {Color color = Colors.yellow}) {
  if (fullText == 'null') {
    return const TextSpan(
      text: 'ยังไม่ได้ระบุ',
      style: TextStyle(
        fontFamily: 'THSarabunNew',
        fontSize: 22,
        color: Colors.red,
      ),
    );
  }

  if (wordsToHighlight.isEmpty) {
    return TextSpan(text: fullText);
  }

  final wordsToHighlightRegex = wordsToHighlight.join('|');

  final matches = RegExp(wordsToHighlightRegex).allMatches(fullText);
  final highlightedSpans = <TextSpan>[];

  var lastIndex = 0;
  for (final match in matches) {
    final matchStart = match.start;
    final matchEnd = match.end;

    if (lastIndex != matchStart) {
      final nonHighlightedText = fullText.substring(lastIndex, matchStart);
      highlightedSpans.add(TextSpan(text: nonHighlightedText));
    }

    final highlightedText = fullText.substring(matchStart, matchEnd);
    highlightedSpans.add(
      TextSpan(
        text: highlightedText,
        style: TextStyle(backgroundColor: color),
      ),
    );

    lastIndex = matchEnd;
  }

  if (lastIndex != fullText.length) {
    final nonHighlightedText = fullText.substring(lastIndex);
    highlightedSpans.add(TextSpan(text: nonHighlightedText));
  }

  return TextSpan(
    children: highlightedSpans,
    style: const TextStyle(
      fontFamily: 'THSarabunNew',
      fontSize: 24,
      color: Colors.blue,
    ),
  );
}
