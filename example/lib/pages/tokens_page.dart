import 'package:flutter/material.dart';
import 'package:naali_ui/naali_ui.dart';

import '../main.dart';

/// Colours, type scale and radii of the active theme.
class TokensPage extends StatelessWidget {
  const TokensPage({super.key, required this.tabIndex});
  final int tabIndex;

  String _hex(Color c) => '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final colors = <(String, Color)>[
      ('background', c.background),
      ('surface', c.surface),
      ('surfaceRaised', c.surfaceRaised),
      ('hairline', c.hairline),
      ('accent', c.accent),
      ('inverse', c.inverse),
      ('textPrimary', c.textPrimary),
      ('textSecondary', c.textSecondary),
      ('textTertiary', c.textTertiary),
      ('success', c.success),
      ('warning', c.warning),
      ('danger', c.danger),
      ('info', c.info),
      ('violet', c.violet),
      ('chartMuted', c.chartMuted),
    ];
    final type = <(String, TextStyle)>[
      ('largeTitle · 32', NaaliType.largeTitle),
      ('title1 · 26', NaaliType.title1),
      ('title2 · 20', NaaliType.title2),
      ('section · 19', NaaliType.section),
      ('headline · 16', NaaliType.headline),
      ('rowTitle · 15.5', NaaliType.rowTitle),
      ('body · 15', NaaliType.bodyText),
      ('callout · 14', NaaliType.callout),
      ('caption · 13', NaaliType.caption),
      ('micro · 11', NaaliType.micro),
    ];
    return NCollapsingPage(
      title: 'Tokens',
      tabIndex: tabIndex,
      actions: const [ThemeToggle()],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: NaaliSpace.page),
          sliver: SliverList.list(children: [
            const NSectionHeader('Colour'),
            NListGroup(dividerIndent: 16, children: [
              for (final (name, color) in colors)
                NListItem(
                  dense: true,
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.hairline),
                    ),
                  ),
                  title: name,
                  trailingSubtitle: _hex(color),
                ),
            ]),
            const NSectionHeader('Typography'),
            NCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (name, style) in type) ...[
                    Text(name, style: NaaliType.micro.copyWith(color: c.textTertiary)),
                    const SizedBox(height: 2),
                    Text('Send money abroad', style: style.copyWith(color: c.textPrimary)),
                    const SizedBox(height: 14),
                  ],
                  Text('number · tabular', style: NaaliType.micro.copyWith(color: c.textTertiary)),
                  const SizedBox(height: 4),
                  Text('0123456789', style: NaaliType.number(30, color: c.textPrimary)),
                ],
              ),
            ),
            const NSectionHeader('Radius'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final (n, r) in const [
                  ('xs', NaaliRadius.xs),
                  ('field', NaaliRadius.field),
                  ('card', NaaliRadius.card),
                  ('sheet', NaaliRadius.sheet),
                  ('pill', 40.0),
                ])
                  Column(children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(r)),
                      alignment: Alignment.center,
                      child: Text(r == 40 ? '∞' : r.toStringAsFixed(0), style: NaaliType.number(18, color: c.textPrimary)),
                    ),
                    const SizedBox(height: 6),
                    Text(n, style: NaaliType.caption.copyWith(color: c.textSecondary)),
                  ]),
              ],
            ),
            const NSectionHeader('Spacing'),
            NCard(
              child: Column(children: [
                for (final (n, v) in const [
                  ('xs', NaaliSpace.xs),
                  ('sm', NaaliSpace.sm),
                  ('md', NaaliSpace.md),
                  ('lg', NaaliSpace.lg),
                  ('xl', NaaliSpace.xl),
                  ('xxl', NaaliSpace.xxl),
                  ('xxxl', NaaliSpace.xxxl),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      SizedBox(width: 44, child: Text(n, style: NaaliType.caption.copyWith(color: c.textSecondary))),
                      Container(width: v * 4, height: 10, decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 8),
                      Text('${v.toInt()}', style: NaaliType.caption.copyWith(color: c.textPrimary)),
                    ]),
                  ),
              ]),
            ),
          ]),
        ),
      ],
    );
  }
}
