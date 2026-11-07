import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'pressable.dart';

/// Rounded linear progress (budgets, savings goals). Animates between values.
/// Fills the available width, so it needs a bounded width (not a bare [Row] child).
class NProgressBar extends StatelessWidget {
  const NProgressBar({
    super.key,
    required this.value,
    this.color,
    this.trackColor,
    this.height = 8,
    this.animate = true,
  });
  final double value;
  final Color? color;

  /// Defaults to `surfaceRaised`; pass something lighter for bars on glass or raised cards.
  final Color? trackColor;
  final double height;

  /// False for values that already update smoothly (live readouts), so the bar doesn't lag behind.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      // Full width even under loose constraints (e.g. a start-aligned Column);
      // otherwise the Stack would shrink the track to the filled fraction.
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value.clamp(0.0, 1.0)),
          duration: animate ? NaaliMotion.slow : Duration.zero,
          curve: NaaliMotion.curve,
          builder: (context, v, _) => Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: trackColor ?? c.surfaceRaised)),
              FractionallySizedBox(
                widthFactor: v,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color ?? c.accent, borderRadius: BorderRadius.circular(height)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular progress ring with content in the middle (e.g. "62%").
class NProgressRing extends StatelessWidget {
  const NProgressRing({super.key, required this.value, this.size = 72, this.stroke = 7, this.color, this.child});
  final double value;
  final double size;
  final double stroke;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0.0, 1.0)),
      duration: NaaliMotion.slow,
      curve: NaaliMotion.curve,
      builder: (context, v, child) => CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(v, stroke, color ?? c.accent, c.surfaceRaised),
        child: SizedBox.square(dimension: size, child: Center(child: child)),
      ),
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.stroke, this.color, this.track);
  final double value;
  final double stroke;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, p..color = track);
    if (value > 0) canvas.drawArc(r, -math.pi / 2, math.pi * 2 * value, false, p..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.color != color || old.track != track;
}

/// Grey placeholder block. Wrap a layout of these in [NShimmer].
class NSkeleton extends StatelessWidget {
  const NSkeleton({super.key, this.width, required this.height, this.radius = 8, this.circle = false});
  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
        width: circle ? height : width,
        height: height,
        decoration: BoxDecoration(
          color: context.naali.surfaceRaised,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
        ),
      );
}

/// Sweeps a soft highlight across its child to signal loading.
class NShimmer extends StatefulWidget {
  const NShimmer({super.key, required this.child});
  final Widget child;

  @override
  State<NShimmer> createState() => _NShimmerState();
}

class _NShimmerState extends State<NShimmer> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = context.naali.isDark ? const Color(0x14FFFFFF) : const Color(0x99FFFFFF);
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _c.value * 2 - 0.5;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            colors: [hi.withAlpha(0), hi, hi.withAlpha(0)],
            stops: [t - 0.3, t, t + 0.3].map((s) => s.clamp(0.0, 1.0)).toList(),
          ).createShader(rect),
          child: child,
        );
      },
    );
  }
}

/// Loading placeholder shaped like a card of list rows.
class NSkeletonList extends StatelessWidget {
  const NSkeletonList({super.key, this.rows = 4});
  final int rows;

  @override
  Widget build(BuildContext context) => NShimmer(
        child: Material(
          color: context.naali.surface,
          borderRadius: BorderRadius.circular(NaaliRadius.card),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < rows; i++)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        NSkeleton(height: 40, circle: true),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NSkeleton(width: 150, height: 13),
                              SizedBox(height: 8),
                              NSkeleton(width: 96, height: 10),
                            ],
                          ),
                        ),
                        NSkeleton(width: 52, height: 13),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}

class NEmptyState extends StatelessWidget {
  const NEmptyState({super.key, required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: c.surfaceRaised, shape: BoxShape.circle),
            child: Icon(icon, size: 30, color: c.textPrimary),
          ),
          const SizedBox(height: 20),
          Text(title, style: NaaliType.title2.copyWith(color: c.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message, style: NaaliType.callout.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    );
  }
}

enum NBannerTone { info, success, warning, danger }

/// Inline callout card: icon, title, message, optional action and close.
class NBanner extends StatelessWidget {
  const NBanner({
    super.key,
    required this.title,
    this.message,
    this.tone = NBannerTone.info,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onClose,
  });

  final String title;
  final String? message;
  final NBannerTone tone;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final (color, defaultIcon) = switch (tone) {
      NBannerTone.info => (c.accent, Icons.info_rounded),
      NBannerTone.success => (c.success, Icons.check_circle_rounded),
      NBannerTone.warning => (c.warning, Icons.warning_rounded),
      NBannerTone.danger => (c.danger, Icons.error_rounded),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: c.isDark ? 0.12 : 0.08), c.surface),
        borderRadius: BorderRadius.circular(NaaliRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: NaaliType.headline.copyWith(color: c.textPrimary, fontSize: 15)),
                if (message != null) ...[
                  const SizedBox(height: 3),
                  Text(message!, style: NaaliType.callout.copyWith(color: c.textSecondary, height: 1.35)),
                ],
                if (actionLabel != null) ...[
                  const SizedBox(height: 10),
                  NPressable(
                    onTap: onAction,
                    child: Text(actionLabel!, style: NaaliType.callout.copyWith(color: color, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null)
            NPressable(
              onTap: onClose,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 20, color: c.textSecondary),
              ),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}
