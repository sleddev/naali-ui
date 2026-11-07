import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'pressable.dart';

/// Pill filter chip: inverse (white on dark) when selected, raised grey otherwise.
class NPillChip extends StatelessWidget {
  const NPillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  /// After the label, e.g. a ▾ for a filter chip that opens a picker.
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final fg = selected ? c.onInverse : c.textPrimary;
    return NPressable(
      onTap: onTap,
      scale: 0.95,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: NaaliMotion.fast,
        padding: EdgeInsets.fromLTRB(icon == null ? 16 : 12, 9, trailingIcon == null ? 16 : 10, 9),
        decoration: ShapeDecoration(shape: const StadiumBorder(), color: selected ? c.inverse : c.surfaceRaised),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 6)],
            AnimatedDefaultTextStyle(
              duration: NaaliMotion.fast,
              style: NaaliType.callout.copyWith(fontWeight: FontWeight.w500, color: fg, height: 1.2),
              child: Text(label),
            ),
            if (trailingIcon != null) ...[const SizedBox(width: 2), Icon(trailingIcon, size: 18, color: fg)],
          ],
        ),
      ),
    );
  }
}

/// Horizontal, scrollable row of [NPillChip]s acting as a single-select tab bar.
class NPillTabs<T> extends StatelessWidget {
  const NPillTabs({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
    this.padding = EdgeInsets.zero,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: Row(
          children: [
            for (final v in values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: NPillChip(label: label(v), selected: v == selected, onTap: () => onChanged(v)),
              ),
          ],
        ),
      );
}

enum NTagTone { neutral, accent, success, warning, danger }

/// Small status label ("Pending", "Declined", "New").
class NTag extends StatelessWidget {
  const NTag(this.label, {super.key, this.tone = NTagTone.neutral, this.icon});

  final String label;
  final NTagTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final fg = switch (tone) {
      NTagTone.neutral => c.textSecondary,
      NTagTone.accent => c.accent,
      NTagTone.success => c.success,
      NTagTone.warning => c.warning,
      NTagTone.danger => c.danger,
    };
    final bg = tone == NTagTone.neutral ? c.surfaceRaised : fg.withValues(alpha: 0.14);
    return Container(
      padding: EdgeInsets.fromLTRB(icon == null ? 8 : 6, 3, 8, 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(NaaliRadius.xs)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: fg), const SizedBox(width: 3)],
          Text(label, style: NaaliType.micro.copyWith(color: fg, fontWeight: FontWeight.w600, fontSize: 11.5)),
        ],
      ),
    );
  }
}

/// Red count bubble for notifications. Wrap a child to place it on its corner.
class NCountBadge extends StatelessWidget {
  const NCountBadge({super.key, required this.count, this.child});
  final int count;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final bubble = Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: ShapeDecoration(shape: const StadiumBorder(), color: c.danger),
      child: Text(count > 99 ? '99+' : '$count',
          style: NaaliType.micro.copyWith(color: Colors.white, fontWeight: FontWeight.w700, height: 1)),
    );
    if (child == null) return bubble;
    return Stack(
      clipBehavior: Clip.none,
      children: [child!, if (count > 0) Positioned(top: -4, right: -4, child: bubble)],
    );
  }
}

/// Sliding segmented control: a raised track with a thumb that glides to the selection.
class NSegmentedControl<T> extends StatelessWidget {
  const NSegmentedControl({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
    this.height = 40,
    this.icon,
    this.onDeselect,
  });

  final List<T> values;

  /// Null shows no thumb (nothing chosen yet).
  final T? selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  final double height;

  /// Optional icon before each label.
  final IconData? Function(T)? icon;

  /// Makes the choice optional: tapping the selected segment calls this.
  final VoidCallback? onDeselect;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final index = selected == null ? -1 : values.indexOf(selected as T);
    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: ShapeDecoration(shape: const StadiumBorder(), color: c.surfaceRaised),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth / values.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: NaaliMotion.normal,
                curve: NaaliMotion.curve,
                left: w * (index < 0 ? 0 : index),
                top: 0,
                bottom: 0,
                width: w,
                child: AnimatedOpacity(
                  opacity: index < 0 ? 0 : 1,
                  duration: NaaliMotion.fast,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: const StadiumBorder(),
                      color: c.isDark ? const Color(0xFF3A3B41) : Colors.white,
                      shadows: c.isDark
                          ? null
                          : const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1))],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < values.length; i++)
                    Expanded(
                      child: Semantics(
                        selected: i == index,
                        button: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (i == index && onDeselect == null) return;
                            NaaliHaptics.tap();
                            i == index ? onDeselect!() : onChanged(values[i]);
                          },
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (icon?.call(values[i]) case final ic?) ...[
                                  Icon(ic, size: 18, color: i == index ? c.textPrimary : c.textSecondary),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: AnimatedDefaultTextStyle(
                                    duration: NaaliMotion.fast,
                                    style: NaaliType.callout.copyWith(
                                      fontWeight: FontWeight.w600,
                                      height: 1.1,
                                      color: i == index ? c.textPrimary : c.textSecondary,
                                    ),
                                    child: Text(label(values[i]), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
