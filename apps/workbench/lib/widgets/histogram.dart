import 'package:dca75_store/dca75_store.dart';
import 'package:flutter/material.dart';

import '../app/format.dart';

/// Bar histogram of a bin statistic with an optional marker for one value.
class HistogramChart extends StatelessWidget {
  const HistogramChart({
    super.key,
    required this.stats,
    this.marker,
    this.height = 120,
    this.showAxis = true,
  });

  final BinStats stats;
  final double? marker;
  final double height;
  final bool showAxis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _HistogramPainter(
          stats: stats,
          marker: marker,
          bar: theme.colorScheme.primary.withValues(alpha: 0.55),
          markerColor: theme.colorScheme.error,
          axis: theme.colorScheme.onSurfaceVariant,
          textStyle:
              theme.textTheme.labelSmall ?? const TextStyle(fontSize: 10),
          showAxis: showAxis,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _HistogramPainter extends CustomPainter {
  _HistogramPainter({
    required this.stats,
    required this.marker,
    required this.bar,
    required this.markerColor,
    required this.axis,
    required this.textStyle,
    required this.showAxis,
  });

  final BinStats stats;
  final double? marker;
  final Color bar, markerColor, axis;
  final TextStyle textStyle;
  final bool showAxis;

  @override
  void paint(Canvas canvas, Size size) {
    final h = stats.histogram;
    if (h.isEmpty) return;
    final bottom = showAxis ? size.height - 14 : size.height;
    final maxCount = h
        .map((b) => b.count)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final lo = h.first.lo, hi = h.last.hi;
    final span = hi - lo == 0 ? 1 : hi - lo;
    double px(double x) => (x - lo) / span * size.width;

    final paint = Paint()..color = bar;
    for (final b in h) {
      final l = px(b.lo), r = px(b.hi);
      final top =
          bottom - (maxCount == 0 ? 0 : b.count / maxCount * (bottom - 4));
      canvas.drawRect(Rect.fromLTRB(l + 1, top, r - 1, bottom), paint);
    }
    canvas.drawLine(
      Offset(0, bottom),
      Offset(size.width, bottom),
      Paint()..color = axis,
    );

    if (showAxis) {
      for (final (x, align) in [(lo, TextAlign.left), (hi, TextAlign.right)]) {
        final tp = TextPainter(
          text: TextSpan(
            text: fmtValue(stats.key, x),
            style: textStyle.copyWith(color: axis),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final dx = align == TextAlign.left ? 0.0 : size.width - tp.width;
        tp.paint(canvas, Offset(dx, bottom + 1));
      }
    }

    final m = marker;
    if (m != null && m >= lo && m <= hi) {
      final x = px(m);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, bottom),
        Paint()
          ..color = markerColor
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_HistogramPainter old) =>
      old.stats != stats || old.marker != marker || old.bar != bar;
}
