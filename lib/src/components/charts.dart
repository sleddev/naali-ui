import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'surfaces.dart';

/// Chart inside a card with a caption and headline value above it.
class NChartCard extends StatelessWidget {
  const NChartCard({super.key, required this.title, required this.child, this.value, this.trailing});
  final String title;
  final String? value;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return NCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: NaaliType.caption.copyWith(color: c.textSecondary)),
                    if (value != null) ...[
                      const SizedBox(height: 4),
                      Text(value!, style: NaaliType.number(22, color: c.textPrimary)),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// Smooth line with a fading fill and an end dot. Values are normalised to the box.
class NSparkline extends StatelessWidget {
  const NSparkline({super.key, required this.values, this.height = 80, this.color, this.fill = true});
  final List<double> values;
  final double height;
  final Color? color;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: NaaliMotion.curve,
      builder: (context, t, _) => CustomPaint(
        size: Size(double.infinity, height),
        painter: _SparkPainter(values, color ?? c.accent, fill, t, c.surface),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.color, this.fill, this.t, this.surface);
  final List<double> values;
  final Color color;
  final bool fill;
  final double t;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final lo = values.reduce(math.min), hi = values.reduce(math.max);
    final span = (hi - lo) == 0 ? 1 : hi - lo;
    const inset = 6.0;
    final pts = [
      for (var i = 0; i < values.length; i++)
        Offset(
          i / (values.length - 1) * size.width,
          inset + (1 - (values[i] - lo) / span) * (size.height - inset * 2),
        ),
    ];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final a = pts[i - 1], b = pts[i];
      final mx = (a.dx + b.dx) / 2;
      path.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
    }
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * t, size.height));
    if (fill) {
      final area = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
    if (t >= 1) {
      canvas.drawCircle(pts.last, 5.5, Paint()..color = surface);
      canvas.drawCircle(pts.last, 4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.values != values || old.t != t || old.color != color;
}

class NBarDatum {
  const NBarDatum(this.label, this.value);
  final String label;
  final double value;
}

/// Rounded bars; the selected bar is accent, the rest muted. Tap a bar to select it.
class NBarChart extends StatelessWidget {
  const NBarChart({super.key, required this.data, this.selected, this.onSelect, this.height = 140});
  final List<NBarDatum> data;
  final int? selected;
  final ValueChanged<int>? onSelect;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final hi = data.isEmpty ? 1.0 : data.map((d) => d.value).reduce(math.max);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < data.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSelect == null
                    ? null
                    : () {
                        NaaliHaptics.tap();
                        onSelect!(i);
                      },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: hi == 0 ? 0 : data[i].value / hi),
                          duration: NaaliMotion.slow,
                          curve: NaaliMotion.curve,
                          builder: (context, f, _) => FractionallySizedBox(
                            heightFactor: math.max(f, 0.02),
                            widthFactor: 0.62,
                            child: AnimatedContainer(
                              duration: NaaliMotion.normal,
                              decoration: BoxDecoration(
                                color: i == selected ? c.accent : c.chartMuted,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data[i].label,
                      style: NaaliType.micro.copyWith(color: i == selected ? c.textPrimary : c.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NSegment {
  const NSegment(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

/// Horizontal stacked bar with a legend: spending by category.
class NBreakdownBar extends StatelessWidget {
  const NBreakdownBar({super.key, required this.segments, this.height = 12, this.legend = true, this.format});
  final List<NSegment> segments;
  final double height;
  final bool legend;
  final String Function(double)? format;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final total = segments.fold<double>(0, (a, s) => a + s.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                for (var i = 0; i < segments.length; i++) ...[
                  if (i > 0) SizedBox(width: 2, child: ColoredBox(color: c.surface)),
                  Expanded(
                    flex: total == 0 ? 1 : math.max(1, (segments[i].value / total * 1000).round()),
                    child: ColoredBox(color: segments[i].color),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (legend) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final s in segments)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(s.label, style: NaaliType.caption.copyWith(color: c.textSecondary)),
                    if (format != null) ...[
                      const SizedBox(width: 4),
                      Text(format!(s.value), style: NaaliType.caption.copyWith(color: c.textPrimary)),
                    ],
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}
