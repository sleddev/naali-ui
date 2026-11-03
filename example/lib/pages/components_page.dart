import 'package:flutter/material.dart';
import 'package:naali_ui/naali_ui.dart';

import '../main.dart';
import 'demos.dart';

class _Entry {
  const _Entry(this.title, this.subtitle, this.icon, this.page);
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() page;
}

final _groups = <String, List<_Entry>>{
  'Actions': [
    _Entry('Buttons', 'Primary, secondary, inverse, tertiary', Icons.smart_button_rounded, () => const ButtonsDemo()),
    _Entry('Icon buttons & actions', 'Circle buttons, quick-action row', Icons.radio_button_checked_rounded,
        () => const ActionsDemo()),
  ],
  'Content': [
    _Entry('Lists', 'Rows, groups, detail rows', Icons.view_list_rounded, () => const ListsDemo()),
    _Entry('Avatars', 'Initials, icons, badges, stacks', Icons.account_circle_rounded, () => const AvatarsDemo()),
    _Entry('Amounts & stats', 'Balances, figures, deltas', Icons.euro_rounded, () => const AmountsDemo()),
    _Entry('Cards', 'Surfaces, glass, payment cards', Icons.credit_card_rounded, () => const CardsDemo()),
    _Entry('Charts', 'Bars, sparkline, breakdown', Icons.bar_chart_rounded, () => const ChartsDemo()),
  ],
  'Input': [
    _Entry('Chips, tabs & tags', 'Pill chips, segmented control', Icons.label_rounded, () => const ChipsDemo()),
    _Entry('Selection controls', 'Switch, checkbox, radio, slider', Icons.toggle_on_rounded, () => const ControlsDemo()),
    _Entry('Text fields', 'Filled fields, search', Icons.text_fields_rounded, () => const FieldsDemo()),
    _Entry('Keypad & PIN', 'Amount entry, passcode', Icons.dialpad_rounded, () => const KeypadDemo()),
  ],
  'Feedback': [
    _Entry('Sheets & toasts', 'Bottom sheets, confirm, action list', Icons.vertical_align_top_rounded,
        () => const SheetsDemo()),
    _Entry('Progress & loading', 'Bars, rings, skeletons', Icons.hourglass_bottom_rounded, () => const ProgressDemo()),
    _Entry('Banners & empty states', 'Callouts, zero data', Icons.campaign_rounded, () => const BannersDemo()),
  ],
};

class ComponentsPage extends StatefulWidget {
  const ComponentsPage({super.key, required this.tabIndex});
  final int tabIndex;

  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<ComponentsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final groups = {
      for (final g in _groups.entries)
        g.key: g.value.where((e) => q.isEmpty || '${e.title} ${e.subtitle}'.toLowerCase().contains(q)).toList(),
    }..removeWhere((_, v) => v.isEmpty);

    return NCollapsingPage(
      title: 'Components',
      tabIndex: widget.tabIndex,
      actions: const [ThemeToggle()],
      header: NSearchField(hint: 'Search components', onChanged: (v) => setState(() => _query = v)),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: NaaliSpace.page),
          sliver: SliverList.list(children: [
            if (groups.isEmpty)
              const NEmptyState(
                icon: Icons.search_off_rounded,
                title: 'No components',
                message: 'Try a different search term.',
              ),
            for (final g in groups.entries) ...[
              NSectionHeader(g.key, padding: const EdgeInsets.fromLTRB(4, 24, 4, 10)),
              NListGroup(children: [
                for (final e in g.value)
                  NListItem(
                    leading: NAvatar.icon(e.icon, color: context.naali.accent),
                    title: e.title,
                    subtitle: e.subtitle,
                    chevron: true,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => e.page())),
                  ),
              ]),
            ],
          ]),
        ),
      ],
    );
  }
}
