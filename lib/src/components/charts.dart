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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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

/// Two counts that share one whole (left vs right turns, wins vs losses) as
/// one bar, labelled with name and figure at both ends.
class NSplitBar extends StatelessWidget {
  const NSplitBar({
    super.key,
    required this.leftLabel,
    required this.left,
    required this.rightLabel,
    required this.right,
    this.leftColor,
    this.rightColor,
    this.height = NaaliSpace.sm,
    this.format,
  });

  final String leftLabel;
  final num left;
  final String rightLabel;
  final num right;

  /// Defaults to the accent.
  final Color? leftColor;

  /// Defaults to `chartMuted`.
  final Color? rightColor;
  final double height;

  /// Formats the figures; defaults to `toString`.
  final String Function(num)? format;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final total = left + right;
    final share = total <= 0 ? 0.5 : left / total;
    String fmt(num v) => format?.call(v) ?? '$v';
    final name = NaaliType.caption.copyWith(color: c.textSecondary);
    final figure = NaaliType.number(17, color: c.textPrimary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(NaaliRadius.pill),
          child: SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: (share * 1000).round().clamp(1, 999), child: ColoredBox(color: leftColor ?? c.accent)),
                SizedBox(width: NaaliSpace.xxs, child: ColoredBox(color: c.surface)),
                Expanded(
                  flex: ((1 - share) * 1000).round().clamp(1, 999),
                  child: ColoredBox(color: rightColor ?? c.chartMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: NaaliSpace.sm),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(child: Text(leftLabel, style: name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: NaaliSpace.xs),
                  Text(fmt(left), style: figure),
                ],
              ),
            ),
            const SizedBox(width: NaaliSpace.md),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(fmt(right), style: figure),
                  const SizedBox(width: NaaliSpace.xs),
                  Flexible(child: Text(rightLabel, style: name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One line of a [NChartTip]: an optional series swatch and name, then the value.
class NChartTipRow {
  const NChartTipRow(this.value, {this.label, this.color, this.dashed = false});
  final String value;
  final String? label;

  /// Series colour, shown as a swatch. Leave null on single-series charts.
  final Color? color;

  /// Draws the swatch as a short dashed line, for series drawn dashed.
  final bool dashed;
}

/// What a [NChartTooltip] shows, and where.
class NChartTip {
  const NChartTip({required this.anchor, required this.rows, this.title});

  /// The point the tip is about, in the [NChartTooltip]'s local coordinates.
  final Offset anchor;
  final String? title;
  final List<NChartTipRow> rows;
}

/// Hosts a chart and floats its tooltip in the app overlay, so a clipping card around the chart
/// can't cut it off. The tip sits above its anchor, flips below when there's no room, and stays
/// inside the screen gutters. Works with any chart: map a touch to an anchor in this widget's
/// coordinates and the rows to show.
class NChartTooltip extends StatefulWidget {
  const NChartTooltip({super.key, required this.builder});

  /// Builds the chart; call `show` from its touch callback with a tip, or null to hide it.
  final Widget Function(BuildContext context, ValueChanged<NChartTip?> show) builder;

  @override
  State<NChartTooltip> createState() => _NChartTooltipState();
}

class _NChartTooltipState extends State<NChartTooltip> {
  final _portal = OverlayPortalController();
  final _tip = ValueNotifier<NChartTip?>(null);

  // Kept while the tip fades out after the finger lifts.
  NChartTip? _last;

  void _show(NChartTip? tip) {
    if (tip != null) {
      _last = tip;
      if (!_portal.isShowing) _portal.show();
    }
    _tip.value = tip;
  }

  @override
  void dispose() {
    _tip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (overlayContext) => ValueListenableBuilder(
          valueListenable: _tip,
          builder: (_, tip, _) {
            final shown = tip ?? _last;
            final host = context.findRenderObject() as RenderBox?;
            final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
            if (shown == null || host == null || overlay == null || !host.attached) return const SizedBox();
            final anchor = host.localToGlobal(shown.anchor, ancestor: overlay);
            return IgnorePointer(
              child: CustomSingleChildLayout(
                delegate: _ChartTipLayout(anchor, MediaQuery.paddingOf(context)),
                child: AnimatedOpacity(
                  opacity: tip == null ? 0 : 1,
                  duration: NaaliMotion.fast,
                  curve: NaaliMotion.curve,
                  onEnd: () {
                    if (_tip.value == null && _portal.isShowing) _portal.hide();
                  },
                  child: _ChartTipCard(shown),
                ),
              ),
            );
          },
        ),
        child: widget.builder(context, _show),
      );
}

class _ChartTipLayout extends SingleChildLayoutDelegate {
  _ChartTipLayout(this.anchor, this.safe);
  final Offset anchor;
  final EdgeInsets safe;

  static const _gap = NaaliSpace.md;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(constraints.biggest).deflate(const EdgeInsets.all(NaaliSpace.page));

  @override
  Offset getPositionForChild(Size size, Size child) {
    final x = (anchor.dx - child.width / 2)
        .clamp(NaaliSpace.page, (size.width - child.width - NaaliSpace.page).clamp(NaaliSpace.page, double.infinity));
    final above = anchor.dy - _gap - child.height;
    final y = above >= safe.top + NaaliSpace.sm ? above : anchor.dy + _gap;
    return Offset(x.toDouble(), y);
  }

  @override
  bool shouldRelayout(_ChartTipLayout old) => old.anchor != anchor || old.safe != safe;
}

class _ChartTipCard extends StatelessWidget {
  const _ChartTipCard(this.tip);
  final NChartTip tip;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final muted = c.onInverse.withValues(alpha: 0.62);
    final title = tip.title;
    final swatches = tip.rows.any((r) => r.color != null);
    final labels = tip.rows.any((r) => r.label != null);
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.fromLTRB(NaaliSpace.md, NaaliSpace.sm, NaaliSpace.md, NaaliSpace.sm),
      decoration: BoxDecoration(
        color: c.inverse,
        borderRadius: BorderRadius.circular(NaaliRadius.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: NaaliType.micro.copyWith(color: muted)),
            const SizedBox(height: NaaliSpace.xs),
          ],
          Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              for (final (i, r) in tip.rows.indexed)
                TableRow(children: [
                  if (swatches)
                    _tipCell(i, NaaliSpace.sm, r.color == null ? const SizedBox() : _ChartTipSwatch(r.color!, dashed: r.dashed)),
                  if (labels) _tipCell(i, NaaliSpace.md, Text(r.label ?? '', style: NaaliType.caption.copyWith(color: muted))),
                  _tipCell(
                    i,
                    0,
                    Text(
                      r.value,
                      textAlign: labels ? TextAlign.right : TextAlign.left,
                      style: NaaliType.number(i == 0 ? 15 : 13, color: c.onInverse),
                    ),
                  ),
                ]),
            ],
          ),
        ],
      ),
    );
  }
}

/// Rows after the first get a little air above; [right] separates the cell from the next column.
Widget _tipCell(int row, double right, Widget child) =>
    Padding(padding: EdgeInsets.only(top: row == 0 ? 0 : NaaliSpace.xs, right: right), child: child);

class _ChartTipSwatch extends StatelessWidget {
  const _ChartTipSwatch(this.color, {this.dashed = false});
  final Color color;
  final bool dashed;

  @override
  Widget build(BuildContext context) => dashed
      ? Row(mainAxisSize: MainAxisSize.min, children: [
          _dash(),
          const SizedBox(width: NaaliSpace.xxs),
          _dash(),
        ])
      : Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _dash() =>
      Container(width: 4, height: 2.5, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)));
}
