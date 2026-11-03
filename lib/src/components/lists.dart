import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import '../foundation/typography.dart';

/// Sentence-case section heading with an optional trailing widget (e.g. "See all").
class NSectionHeader extends StatelessWidget {
  const NSectionHeader(
    this.text, {
    super.key,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(4, 28, 4, 12),
  });

  final String text;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Row(
          children: [
            Expanded(child: Text(text, style: NaaliType.section.copyWith(color: context.naali.textPrimary))),
            ?trailing,
          ],
        ),
      );
}

/// The workhorse row: avatar, title + subtitle, and a trailing figure or control.
///
/// Use [trailingTitle]/[trailingSubtitle] for amounts ("-€12.40" / "Pending"),
/// or [trailing] for a switch, checkbox or tag. [chevron] adds a disclosure arrow.
class NListItem extends StatelessWidget {
  const NListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.trailingTitle,
    this.trailingSubtitle,
    this.trailingTitleColor,
    this.onTap,
    this.chevron = false,
    this.destructive = false,
    this.dense = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final String? trailingTitle;
  final String? trailingSubtitle;
  final Color? trailingTitleColor;
  final VoidCallback? onTap;
  final bool chevron;
  final bool destructive;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final hasTrailingText = trailingTitle != null || trailingSubtitle != null;
    final row = Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: dense ? 10 : 12),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 14)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NaaliType.rowTitle.copyWith(color: destructive ? c.danger : c.textPrimary),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: NaaliType.caption.copyWith(color: c.textSecondary, fontWeight: FontWeight.w400),
                  ),
                ],
              ],
            ),
          ),
          if (hasTrailingText) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingTitle != null)
                  Text(
                    trailingTitle!,
                    style: NaaliType.rowTitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: trailingTitleColor ?? c.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                if (trailingSubtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(trailingSubtitle!, style: NaaliType.caption.copyWith(color: c.textSecondary, fontWeight: FontWeight.w400)),
                ],
              ],
            ),
          ],
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          if (chevron) ...[
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 22, color: c.textTertiary),
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: () {
        NaaliHaptics.tap();
        onTap!();
      },
      child: row,
    );
  }
}

/// Card of rows. Rows are separated by space alone; set [dividers] for
/// hairlines inset past the leading avatar.
class NListGroup extends StatelessWidget {
  const NListGroup({
    super.key,
    required this.children,
    this.margin,
    this.dividers = false,
    this.dividerIndent = 70,
    this.title,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final bool dividers;

  /// Left inset of [dividers]; 70 aligns with text after a 40px avatar. Use 16 without avatars.
  final double dividerIndent;

  /// Optional quiet heading inside the card ("Today", "Address", "Features").
  final String? title;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final group = Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(NaaliRadius.card),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                child: Text(title!, style: NaaliType.bodyText.copyWith(color: c.textSecondary, height: 1.2)),
              ),
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0 && dividers) Divider(indent: dividerIndent, endIndent: 16, height: 1),
              children[i],
            ],
          ],
        ),
      ),
    );
    return margin == null ? group : Padding(padding: margin!, child: group);
  }
}

/// Label-left / value-right row for secondary figures. Use inside [NDetailGroup].
///
/// Tappable values ("To the moon ··9344", "Download") take [valueColor] of
/// `c.accent` and an [icon], which sits before the value in the same colour
/// and replaces the chevron.
class NDetailRow extends StatelessWidget {
  const NDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.onTap,
    this.trailing,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final color = valueColor ?? c.textPrimary;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      // Loose flexibles plus spaceBetween: the label keeps its width, the value
      // hugs the right edge, and long values may take up to two thirds.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: NaaliType.bodyLarge.copyWith(color: c.textSecondary, height: 1.2))),
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20, color: color), const SizedBox(width: 10)],
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: NaaliType.bodyLarge.copyWith(
                        height: 1.2,
                        color: color,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 8), trailing!],
                  if (onTap != null && icon == null) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 20, color: c.textTertiary),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

/// Card of [NDetailRow]s.
class NDetailGroup extends StatelessWidget {
  const NDetailGroup({super.key, required this.rows, this.margin});
  final List<Widget> rows;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) => NListGroup(margin: margin, dividerIndent: 16, children: rows);
}
