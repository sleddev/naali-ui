import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/typography.dart';

/// Minimal money formatting without intl: "€1,234.50", "-£8.00", "+$12".
abstract final class NMoney {
  static String format(
    num value, {
    String symbol = '€',
    int decimals = 2,
    bool showPlus = false,
    bool trimZeroCents = false,
  }) {
    final neg = value < 0;
    final abs = value.abs();
    var fixed = abs.toStringAsFixed(decimals);
    if (trimZeroCents && decimals > 0 && fixed.endsWith('.${'0' * decimals}')) {
      fixed = fixed.substring(0, fixed.length - decimals - 1);
    }
    final dot = fixed.indexOf('.');
    final whole = dot < 0 ? fixed : fixed.substring(0, dot);
    final frac = dot < 0 ? '' : fixed.substring(dot);
    final grouped = whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    final sign = neg ? '-' : (showPlus && value > 0 ? '+' : '');
    return '$sign$symbol$grouped$frac';
  }
}

/// Balance-style headline figure. The decimals (and optional [unit]) are set
/// smaller and lighter, like "€12,480.52".
class NAmount extends StatelessWidget {
  const NAmount(
    this.value, {
    super.key,
    this.unit,
    this.size = 44,
    this.color,
    this.textAlign = TextAlign.start,
  });

  /// Pre-formatted figure, e.g. from [NMoney.format].
  final String value;
  final String? unit;
  final double size;
  final Color? color;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.naali.textPrimary;
    final dot = value.lastIndexOf('.');
    final whole = dot < 0 ? value : value.substring(0, dot);
    final frac = dot < 0 ? '' : value.substring(dot);
    final small = NaaliType.number(size * 0.58, color: fg);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: switch (textAlign) {
        TextAlign.center => Alignment.center,
        TextAlign.end || TextAlign.right => Alignment.centerRight,
        _ => Alignment.centerLeft,
      },
      child: Text.rich(
        TextSpan(children: [
          TextSpan(text: whole, style: NaaliType.number(size, color: fg)),
          if (frac.isNotEmpty) TextSpan(text: frac, style: small),
          if (unit != null) TextSpan(text: ' $unit', style: small),
        ]),
        textAlign: textAlign,
        maxLines: 1,
      ),
    );
  }
}

/// Caption above a figure. Shrinks rather than overflowing in multi-column rows.
class NStatValue extends StatelessWidget {
  const NStatValue({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.size = 24,
    this.color,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final String? unit;
  final double size;
  final Color? color;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: NaaliType.caption.copyWith(color: c.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: switch (crossAxisAlignment) {
            CrossAxisAlignment.center => Alignment.center,
            CrossAxisAlignment.end => Alignment.centerRight,
            _ => Alignment.centerLeft,
          },
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: value, style: NaaliType.number(size, color: color ?? c.textPrimary)),
              if (unit != null)
                TextSpan(
                  text: ' $unit',
                  style: NaaliType.number(size * 0.6, weight: FontWeight.w500, color: c.textSecondary),
                ),
            ]),
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

/// Pill comparing a figure with the previous period ("↑ 12% vs last month").
/// [positiveIsGood] null keeps it neutral; otherwise green/red by direction.
class NDeltaChip extends StatelessWidget {
  const NDeltaChip({super.key, required this.text, required this.direction, this.positiveIsGood});

  final String text;

  /// -1 down, 0 flat, 1 up.
  final int direction;
  final bool? positiveIsGood;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final good = positiveIsGood == null || direction == 0 ? null : (direction > 0) == positiveIsGood;
    final color = good == null ? c.textSecondary : (good ? c.success : c.danger);
    final icon = switch (direction) {
      > 0 => Icons.arrow_upward_rounded,
      < 0 => Icons.arrow_downward_rounded,
      _ => Icons.remove_rounded,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: good == null ? c.surfaceRaised : color.withValues(alpha: 0.14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: NaaliType.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
