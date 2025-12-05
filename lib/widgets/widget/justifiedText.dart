import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class JustifiedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;

  const JustifiedText({
    Key? key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.of(context).size.width;
      // Build lines with measured word widths
      final lines = _buildLines(text, effectiveStyle, maxWidth, maxLines);
      // Render lines: each non-last line will be rendered as a Row with spaced gaps
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines.length, (i) {
          final line = lines[i];
          final isLast = i == lines.length - 1;
          if (line.words.length == 0) return const SizedBox.shrink();

          // If line has only one word OR it's last line -> render normal Text (left aligned)
          if (line.words.length == 1 || isLast) {
            return Text(
              line.words.join(' '),
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: effectiveStyle,
              textAlign: TextAlign.left,
            );
          }

          // else build a Row distributing extra space across gaps
          final gaps = line.words.length - 1;
          final extraTotal = (maxWidth - line.width).clamp(0.0, double.infinity);
          final extraPerGap = extraTotal / gaps;

          // measure base space width
          final spaceWidth = _measureTextWidth(' ', effectiveStyle);

          return Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: line.words.mapIndexed<Widget>((word, idx) {
              if (idx == line.words.length - 1) {
                // last word in the line: just the word
                return Text(word, style: effectiveStyle);
              } else {
                // word + adjusted gap
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(word, style: effectiveStyle),
                    SizedBox(width: spaceWidth + extraPerGap),
                  ],
                );
              }
            }).toList(),
          );
        }),
      );
    });
  }

  // Splits text into words (keeps punctuation attached to words).
  // Then lays out words into lines depending on maxWidth.
  List<_LineMetrics> _buildLines(String text, TextStyle style, double maxWidth, int? maxLines) {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final spaceWidth = _measureTextWidth(' ', style);

    List<_LineMetrics> lines = [];
    double currentWidth = 0;
    List<String> currentWords = [];

    for (var w in words) {
      final wWidth = _measureTextWidth(w, style);
      final projected = currentWords.isEmpty ? wWidth : currentWidth + spaceWidth + wWidth;

      if (projected <= maxWidth || currentWords.isEmpty) {
        // add to current line
        if (currentWords.isEmpty) {
          currentWidth = wWidth;
        } else {
          currentWidth = projected;
        }
        currentWords.add(w);
      } else {
        // finish current line and start new
        lines.add(_LineMetrics(words: List.from(currentWords), width: currentWidth));
        currentWords = [w];
        currentWidth = wWidth;
      }

      // break if reached maxLines (we'll still produce that many lines)
      if (maxLines != null && lines.length + 1 >= maxLines) {
        // collect rest of words into last line (don't keep just single word truncation logic).
        final remaining = [ ...currentWords ] + words.sublist(words.indexOf(w) + 1);
        final lastLineText = remaining.join(' ');
        final lastLineWidth = _measureTextWidth(lastLineText, style);
        lines.add(_LineMetrics(words: remaining, width: lastLineWidth));
        return lines;
      }
    }

    if (currentWords.isNotEmpty) {
      lines.add(_LineMetrics(words: List.from(currentWords), width: currentWidth));
    }

    return lines;
  }

  double _measureTextWidth(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return tp.width;
  }
}

class _LineMetrics {
  final List<String> words;
  final double width;
  _LineMetrics({required this.words, required this.width});
}

/// Small extension to use map with index (keeps flutter stable without extra packages)
extension _MapIndexed<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E element, int index) f) sync* {
    var i = 0;
    for (final e in this) {
      yield f(e, i++);
    }
  }
}
