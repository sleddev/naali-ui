import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';

/// Pill toggle with a white thumb that slides over an accent track.
class NSwitch extends StatelessWidget {
  const NSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    const w = 50.0, h = 30.0, pad = 3.0;
    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      child: GestureDetector(
        onTap: onChanged == null
            ? null
            : () {
                NaaliHaptics.tap();
                onChanged!(!value);
              },
        child: Opacity(
          opacity: onChanged == null ? 0.4 : 1,
          child: AnimatedContainer(
            duration: NaaliMotion.normal,
            curve: NaaliMotion.curve,
            width: w,
            height: h,
            padding: const EdgeInsets.all(pad),
            decoration: ShapeDecoration(shape: const StadiumBorder(), color: value ? c.accent : c.chartMuted),
            child: AnimatedAlign(
              duration: NaaliMotion.normal,
              curve: NaaliMotion.curve,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: h - pad * 2,
                height: h - pad * 2,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1))],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded-square checkbox. Accent fill with a white tick when checked.
class NCheckbox extends StatelessWidget {
  const NCheckbox({super.key, required this.value, required this.onChanged, this.size = 24});
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return Semantics(
      checked: value,
      enabled: onChanged != null,
      child: GestureDetector(
        onTap: onChanged == null
            ? null
            : () {
                NaaliHaptics.tap();
                onChanged!(!value);
              },
        child: AnimatedContainer(
          duration: NaaliMotion.fast,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: value ? c.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(size * 0.3),
            border: Border.all(color: value ? c.accent : c.textTertiary, width: 2),
          ),
          child: AnimatedScale(
            scale: value ? 1 : 0,
            duration: NaaliMotion.fast,
            curve: NaaliMotion.spring,
            child: Icon(Icons.check_rounded, size: size * 0.75, color: c.onAccent),
          ),
        ),
      ),
    );
  }
}

/// Round radio. A thick accent ring when selected.
class NRadio<T> extends StatelessWidget {
  const NRadio({super.key, required this.value, required this.groupValue, required this.onChanged, this.size = 24});
  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final selected = value == groupValue;
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        onTap: onChanged == null
            ? null
            : () {
                NaaliHaptics.tap();
                onChanged!(value);
              },
        child: AnimatedContainer(
          duration: NaaliMotion.fast,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? c.accent : c.textTertiary, width: selected ? size * 0.3 : 2),
          ),
        ),
      ),
    );
  }
}

/// Horizontal step indicator for onboarding / multi-step flows.
class NPageDots extends StatelessWidget {
  const NPageDots({super.key, required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: NaaliMotion.normal,
            curve: NaaliMotion.curve,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 20 : 6,
            height: 6,
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: i == index ? c.textPrimary : c.textTertiary.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}
