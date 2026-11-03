import 'dart:ui';

import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import 'pressable.dart';

/// Solid rounded card on the canvas. No borders, gradients or shadows:
/// hierarchy comes from spacing and type.
class NCard extends StatelessWidget {
  const NCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = NaaliRadius.card,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    Widget card = Material(
      color: color ?? context.naali.surface,
      borderRadius: br,
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
    if (onTap != null) card = NPressable(onTap: onTap, scale: 0.98, child: card);
    return margin == null ? card : Padding(padding: margin!, child: card);
  }
}

/// Frosted surface for controls floating over content (nav bar, map buttons, HUDs).
/// Content pages use [NCard] instead.
class NGlass extends StatelessWidget {
  const NGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.blur = 24,
    this.strong = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final bool strong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final br = BorderRadius.circular(radius);
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: br,
        color: strong ? c.glassFillStrong : c.glassFill,
        border: Border.all(color: c.glassBorder, width: 0.6),
      ),
      child: Padding(padding: padding, child: child),
    );
    final filter = ImageFilter.blur(sigmaX: blur, sigmaY: blur);
    Widget out = ClipRRect(
      borderRadius: br,
      child: blur <= 0
          ? decorated
          : BackdropGroup.of(context) != null
              ? BackdropFilter.grouped(filter: filter, child: decorated)
              : BackdropFilter(filter: filter, child: decorated),
    );
    if (onTap != null) out = NPressable(onTap: onTap, scale: 0.95, child: out);
    return out;
  }
}

/// Circular glass icon button for use over imagery or maps.
class NGlassIconButton extends StatelessWidget {
  const NGlassIconButton({super.key, required this.icon, required this.onPressed, this.size = 44, this.tooltip});

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = SizedBox.square(
      dimension: size,
      child: NGlass(
        radius: size / 2,
        padding: EdgeInsets.zero,
        strong: true,
        onTap: onPressed,
        child: Center(child: Icon(icon, size: size * 0.48, color: context.naali.textPrimary)),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}
