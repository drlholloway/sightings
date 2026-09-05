import 'dart:math' as math;

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter/material.dart';

import '../app/theme.dart';

/// A plotted trace: label, colour, points.
class PlotTrace {
  const PlotTrace({
    required this.label,
    required this.color,
    required this.points,
  });
  final String label;
  final Color color;
  final List<({double x, double y})> points;

  static List<PlotTrace> fromSweep(
    List<SweepTrace> traces, {
    int colorOffset = 0,
    String prefix = '',
  }) => [
    for (final t in traces)
      PlotTrace(
        label: '$prefix${t.label}',
        color: tracePalette[(t.index + colorOffset) % tracePalette.length],
        points: t.points,
      ),
  ];
}

/// Port of the reference client's canvas plotter: auto-ranging with zero
/// snapping, nice ticks, legend, hover read-out.
class CurvePlot extends StatefulWidget {
  const CurvePlot({
    super.key,
    required this.traces,
    required this.xLabel,
    required this.yLabel,
    this.height = 460,
  });
  final List<PlotTrace> traces;
  final String xLabel, yLabel;
  final double height;

  @override
  State<CurvePlot> createState() => _CurvePlotState();
}

class _CurvePlotState extends State<CurvePlot> {
  Offset? _hover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final painter = _PlotPainter(
      traces: widget.traces,
      xLabel: widget.xLabel,
      yLabel: widget.yLabel,
      ink: theme.colorScheme.onSurface,
      grid: theme.colorScheme.outlineVariant,
      muted: theme.colorScheme.onSurfaceVariant,
      background: theme.colorScheme.surface,
      textStyle: theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12),
      hover: _hover,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height,
          child: MouseRegion(
            onHover: (e) => setState(() => _hover = e.localPosition),
            onExit: (_) => setState(() => _hover = null),
            child: GestureDetector(
              onPanDown: (d) => setState(() => _hover = d.localPosition),
              onPanUpdate: (d) => setState(() => _hover = d.localPosition),
              onPanEnd: (_) => setState(() => _hover = null),
              child: ClipRect(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: CustomPaint(painter: painter, size: Size.infinite),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
          child: Text(
            painter.readout ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

List<double> niceTicks(double min, double max, [int n = 6]) {
  if (!(max > min)) max = min + 1;
  final span = max - min, step0 = span / n;
  final mag = math.pow(10, (math.log(step0) / math.ln10).floor()).toDouble();
  final step = [1, 2, 5, 10]
      .map((m) => m * mag)
      .firstWhere((s) => span / s <= n, orElse: () => 10 * mag);
  final t = <double>[];
  for (var v = (min / step).ceil() * step; v <= max + step * 1e-9; v += step) {
    t.add(v);
  }
  return t;
}

class _PlotPainter extends CustomPainter {
  _PlotPainter({
    required this.traces,
    required this.xLabel,
    required this.yLabel,
    required this.ink,
    required this.grid,
    required this.muted,
    required this.background,
    required this.textStyle,
    required this.hover,
  });

  final List<PlotTrace> traces;
  final String xLabel, yLabel;
  final Color ink, grid, muted, background;
  final TextStyle textStyle;
  final Offset? hover;
  String? readout;

  static const double l = 62, r = 150, t = 18, b = 44;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    double xmin = 0, xmax = 1, ymin = 0, ymax = 1;
    var has = false;
    for (final tr in traces) {
      for (final p in tr.points) {
        if (!has) {
          xmin = xmax = p.x;
          ymin = ymax = p.y;
          has = true;
        }
        xmin = math.min(xmin, p.x);
        xmax = math.max(xmax, p.x);
        ymin = math.min(ymin, p.y);
        ymax = math.max(ymax, p.y);
      }
    }
    if (!has) {
      xmin = 0;
      xmax = 10;
      ymin = 0;
      ymax = 10;
    }
    if (xmin > 0 && xmin < xmax * 0.3) xmin = 0;
    if (ymin > 0 && ymin < ymax * 0.3) ymin = 0;
    if (xmax == xmin) xmax = xmin + 1;
    if (ymax == ymin) ymax = ymin + 1;
    ymax += (ymax - ymin) * 0.05;
    xmax += (xmax - xmin) * 0.02;
    double px(double x) => l + (x - xmin) / (xmax - xmin) * (w - l - r);
    double py(double y) => h - b - (y - ymin) / (ymax - ymin) * (h - t - b);

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    void text(
      String s,
      Offset at, {
      TextAlign align = TextAlign.left,
      Color? color,
      double rotate = 0,
    }) {
      final tp = TextPainter(
        text: TextSpan(
          text: s,
          style: textStyle.copyWith(color: color ?? muted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = switch (align) {
        TextAlign.center => -tp.width / 2,
        TextAlign.right => -tp.width,
        _ => 0.0,
      };
      canvas.save();
      canvas.translate(at.dx, at.dy);
      if (rotate != 0) canvas.rotate(rotate);
      tp.paint(canvas, Offset(dx, 0));
      canvas.restore();
    }

    for (final tk in niceTicks(xmin, xmax)) {
      canvas.drawLine(Offset(px(tk), t), Offset(px(tk), h - b), gridPaint);
      text(tick(tk), Offset(px(tk), h - b + 4), align: TextAlign.center);
    }
    for (final tk in niceTicks(ymin, ymax)) {
      canvas.drawLine(Offset(l, py(tk)), Offset(w - r, py(tk)), gridPaint);
      text(tick(tk), Offset(l - 6, py(tk) - 7), align: TextAlign.right);
    }
    canvas.drawRect(
      Rect.fromLTRB(l, t, w - r, h - b),
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    text(
      xLabel,
      Offset(l + (w - l - r) / 2, h - 18),
      align: TextAlign.center,
      color: ink,
    );
    text(
      yLabel,
      Offset(8, t + (h - t - b) / 2),
      align: TextAlign.center,
      color: ink,
      rotate: -math.pi / 2,
    );

    for (final (i, tr) in traces.indexed) {
      final path = Path();
      for (final (j, p) in tr.points.indexed) {
        j == 0 ? path.moveTo(px(p.x), py(p.y)) : path.lineTo(px(p.x), py(p.y));
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = tr.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
      text(tr.label, Offset(w - r + 10, t + 4 + i * 17), color: tr.color);
    }

    final hv = hover;
    if (hv != null &&
        has &&
        hv.dx >= l &&
        hv.dx <= w - r &&
        hv.dy >= t &&
        hv.dy <= h - b) {
      final gx = xmin + (hv.dx - l) / (w - l - r) * (xmax - xmin);
      final gy = ymin + (h - b - hv.dy) / (h - t - b) * (ymax - ymin);
      readout =
          '$xLabel: ${gx.toStringAsPrecision(4)}   $yLabel: ${gy.toStringAsPrecision(4)}';
      canvas.drawLine(
        Offset(hv.dx, t),
        Offset(hv.dx, h - b),
        Paint()..color = muted.withValues(alpha: 0.5),
      );
    } else {
      readout = null;
    }
  }

  @override
  bool shouldRepaint(_PlotPainter old) => true;
}
