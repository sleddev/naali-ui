import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'pressable.dart';

enum NButtonVariant {
  /// Accent fill. One per screen.
  primary,

  /// Raised grey fill. Everything that isn't the main action.
  secondary,

  /// White on dark / black on light. High-emphasis alternative to primary.
  inverse,

  /// Text only, accent coloured.
  tertiary,

  /// Red fill for irreversible actions.
  destructive,
}

enum NButtonSize {
  large(52, 16, 28),
  medium(44, 15, 20),
  small(34, 14, 14);

  const NButtonSize(this.height, this.fontSize, this.padding);
  final double height;
  final double fontSize;
  final double padding;
}

/// Pill button. Set [expand] for full-width page actions.
class NButton extends StatelessWidget {
  const NButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NButtonVariant.primary,
    this.size = NButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  const NButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = NButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand = false,
  }) : variant = NButtonVariant.secondary;

  const NButton.tertiary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = NButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand = false,
  }) : variant = NButtonVariant.tertiary;

  final String label;
  final VoidCallback? onPressed;
  final NButtonVariant variant;
  final NButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final (bg, fg) = switch (variant) {
      NButtonVariant.primary => (c.accent, c.onAccent),
      NButtonVariant.secondary => (c.surfaceRaised, c.textPrimary),
      NButtonVariant.inverse => (c.inverse, c.onInverse),
      NButtonVariant.tertiary => (Colors.transparent, c.accent),
      NButtonVariant.destructive => (c.danger, Colors.white),
    };
    final content = loading
        ? SizedBox.square(
            dimension: size.fontSize + 4,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: size.fontSize + 4, color: fg), const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NaaliType.button.copyWith(fontSize: size.fontSize, color: fg),
                ),
              ),
            ],
          );
    return NPressable(
      onTap: loading ? null : onPressed,
      scale: 0.97,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: NaaliMotion.normal,
        height: size.height,
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: size.padding),
        decoration: ShapeDecoration(shape: const StadiumBorder(), color: bg),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}

/// Solid circular icon button: page headers, inline actions.
class NIconButton extends StatelessWidget {
  const NIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.tooltip,
    this.color,
    this.background,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final btn = NPressable(
      onTap: onPressed,
      scale: 0.92,
      semanticLabel: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background ?? c.surfaceRaised, shape: BoxShape.circle),
        child: Icon(icon, size: size * 0.5, color: color ?? c.textPrimary),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

/// Circle button with a caption under it: the quick-action row under a balance
/// ("Add money", "Move", "Details", "More").
class NCircleAction extends StatelessWidget {
  const NCircleAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
    this.size = 52,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// Accent-filled circle for the action the screen is about.
  final bool highlighted;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return NPressable(
      onTap: onTap,
      scale: 0.94,
      semanticLabel: label,
      child: SizedBox(
        width: size + 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: highlighted ? c.accent : c.surfaceRaised, shape: BoxShape.circle),
              child: Icon(icon, size: size * 0.46, color: highlighted ? c.onAccent : c.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: NaaliType.caption.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Evenly spaced row of [NCircleAction]s.
class NActionRow extends StatelessWidget {
  const NActionRow({super.key, required this.actions});
  final List<NCircleAction> actions;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: actions,
      );
}

/// Small accent text action for section headers ("See all").
class NLinkButton extends StatelessWidget {
  const NLinkButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => NPressable(
        onTap: onPressed,
        scale: 0.95,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Text(label, style: NaaliType.callout.copyWith(color: context.naali.accent, fontWeight: FontWeight.w600)),
        ),
      );
}
