import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'controls.dart';

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
    this.titleSuffix,
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
    this.subtitleMaxLines = 2,
  });

  final String title;

  /// Small widget right after the title, e.g. a favourite star or an [NTag].
  final Widget? titleSuffix;
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

  /// Raise for explanatory subtitles (settings) that shouldn't be cut off.
  final int subtitleMaxLines;

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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NaaliType.rowTitle.copyWith(color: destructive ? c.danger : c.textPrimary),
                      ),
                    ),
                    if (titleSuffix != null) ...[const SizedBox(width: 4), titleSuffix!],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: subtitleMaxLines,
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

/// [NListItem] with a trailing [NSwitch]; tapping anywhere on the row toggles it.
class NSwitchListItem extends StatelessWidget {
  const NSwitchListItem({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
    this.subtitleMaxLines = 2,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final int subtitleMaxLines;
  final bool value;

  /// Null disables the row.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => NListItem(
        title: title,
        subtitle: subtitle,
        leading: leading,
        subtitleMaxLines: subtitleMaxLines,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        trailing: NSwitch(value: value, onChanged: onChanged),
      );
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
    this.color,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final bool dividers;

  /// Left inset of [dividers]; 70 aligns with text after a 40px avatar. Use 16 without avatars.
  final double dividerIndent;

  /// Optional quiet heading inside the card ("Today", "Address", "Features").
  final String? title;

  /// Card fill; defaults to the surface colour. Use `surfaceRaised` inside sheets.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final group = Material(
      color: color ?? c.surface,
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

/// [NListGroup] as a sliver whose rows are built lazily, for long lists (search results, feeds)
/// in a [CustomScrollView]. Reads as one card, like [NListGroup].
class NSliverListGroup extends StatelessWidget {
  const NSliverListGroup.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.dividers = false,
    this.dividerIndent = 70,
    this.title,
    this.color,
  });

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final bool dividers;

  /// Left inset of [dividers]; 70 aligns with text after a 40px avatar. Use 16 without avatars.
  final double dividerIndent;
  final String? title;

  /// Card fill; defaults to the surface colour. Use `surfaceRaised` inside sheets.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final offset = title == null ? 0 : 1;
    final count = itemCount == 0 ? 0 : itemCount + offset;
    const r = Radius.circular(NaaliRadius.card);
    return SliverList.builder(
      itemCount: count,
      itemBuilder: (context, i) {
        final first = i == 0;
        final last = i == count - 1;
        final Widget row;
        if (i < offset) {
          row = Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
            child: Text(title!, style: NaaliType.bodyText.copyWith(color: c.textSecondary, height: 1.2)),
          );
        } else {
          final item = itemBuilder(context, i - offset);
          if (item == null) return null;
          row = dividers && i > offset
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [Divider(indent: dividerIndent, endIndent: 16, height: 1), item],
                )
              : item;
        }
        // Each row paints its slice of the card: rounded only at the ends, with the group's
        // vertical padding on the first and last.
        return Material(
          color: color ?? c.surface,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.vertical(top: first ? r : Radius.zero, bottom: last ? r : Radius.zero),
          child: Padding(
            padding: EdgeInsets.only(top: first ? 6 : 0, bottom: last ? 6 : 0),
            child: row,
          ),
        );
      },
    );
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
      // The value is laid out first, at its natural width but at most two thirds
      // of the row, and hugs the right edge; the label takes whatever is left.
      // (Two loose Flexibles would cap the label at a third even next to a short value.)
      child: LayoutBuilder(
        builder: (context, box) => Row(
          children: [
            Expanded(child: Text(label, style: NaaliType.bodyLarge.copyWith(color: c.textSecondary, height: 1.2))),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: box.maxWidth * 2 / 3),
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
