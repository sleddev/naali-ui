import 'package:flutter/material.dart';
import 'package:naali_ui/naali_ui.dart';

import '../main.dart';
import 'transfer_page.dart';

class Txn {
  const Txn(this.name, this.when, this.amount, {this.icon, this.tag, this.category = 'Shopping'});
  final String name;
  final String when;
  final double amount;
  final IconData? icon;
  final String? tag;
  final String category;
}

const transactions = [
  Txn('Spotify', 'Today, 09:12', -10.99, icon: Icons.music_note_rounded, category: 'Entertainment'),
  Txn('Maya Lindqvist', 'Today, 08:40', 42.50, category: 'Transfers'),
  Txn('Coffee Collective', 'Yesterday, 16:05', -4.20, icon: Icons.local_cafe_rounded, tag: 'Pending', category: 'Eating out'),
  Txn('Uber', 'Yesterday, 01:13', -18.75, icon: Icons.local_taxi_rounded, category: 'Transport'),
  Txn('Salary', '1 Nov, 07:00', 3250.00, icon: Icons.work_rounded, category: 'Income'),
];

/// A banking home screen assembled only from Naali components.
class HomeDemo extends StatefulWidget {
  const HomeDemo({super.key, required this.tabIndex});
  final int tabIndex;

  @override
  State<HomeDemo> createState() => _HomeDemoState();
}

class _HomeDemoState extends State<HomeDemo> {
  final _cards = PageController(viewportFraction: 0.82);
  int _card = 0;
  int _bar = 6;
  String _range = 'Week';
  bool _bannerVisible = true;

  @override
  void dispose() {
    _cards.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final pad = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: c.background,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(NaaliSpace.page, pad.top + 8, NaaliSpace.page, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  NPressable(
                    onTap: () => _profileSheet(context),
                    child: const NAvatar.initials('Alex Morgan', size: 40),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(child: NSearchField(readOnly: true)),
                  const SizedBox(width: 10),
                  NCountBadge(
                    count: 3,
                    child: NIconButton(icon: Icons.notifications_none_rounded, onPressed: () {
                      showNToast(context, 'You have 3 new notifications');
                    }),
                  ),
                  const SizedBox(width: 8),
                  const ThemeToggle(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _balance(context)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverToBoxAdapter(
              child: NActionRow(actions: [
                NCircleAction(
                  icon: Icons.add_rounded,
                  label: 'Add money',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TransferPage(title: 'Add money'))),
                ),
                NCircleAction(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Move',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TransferPage(title: 'Move money'))),
                ),
                NCircleAction(icon: Icons.account_balance_rounded, label: 'Details', onTap: () => _detailsSheet(context)),
                NCircleAction(icon: Icons.more_horiz_rounded, label: 'More', onTap: () => _moreSheet(context)),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(NaaliSpace.page, 20, NaaliSpace.page, 0),
            sliver: SliverList.list(children: [
              if (_bannerVisible)
                NBanner(
                  title: 'Earn 2.25% AER on savings',
                  message: 'Open an instant access savings vault in seconds.',
                  actionLabel: 'Get started',
                  onAction: () => showNToast(context, 'Vault created', tone: NToastTone.success),
                  onClose: () => setState(() => _bannerVisible = false),
                ),
              NSectionHeader('Transactions', trailing: NLinkButton(label: 'See all', onPressed: () {})),
              NListGroup(children: [
                for (final t in transactions) _txnRow(context, t),
              ]),
              const NSectionHeader('Cards'),
            ]),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 210,
                  child: PageView(
                    controller: _cards,
                    padEnds: true,
                    onPageChanged: (i) => setState(() => _card = i),
                    children: [
                      for (final (f, l, n, frozen) in const [
                        (NCardFinish.ocean, 'Virtual', '4242', false),
                        (NCardFinish.midnight, 'Metal', '8810', false),
                        (NCardFinish.sunset, 'Disposable', '1937', true),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Center(
                            child: NPaymentCard(
                              finish: f,
                              label: l,
                              last4: n,
                              frozen: frozen,
                              holder: 'Alex Morgan',
                              onTap: () => showNToast(context, '$l card •• $n'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                NPageDots(count: 3, index: _card),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(NaaliSpace.page, 0, NaaliSpace.page, 0),
            sliver: SliverList.list(children: [
              const NSectionHeader('Spending'),
              NChartCard(
                title: 'Spent this ${_range.toLowerCase()}',
                value: NMoney.format(_range == 'Week' ? 412.36 : 1873.90),
                trailing: const NDeltaChip(text: '8%', direction: -1, positiveIsGood: false),
                child: Column(
                  children: [
                    NBarChart(
                      data: const [
                        NBarDatum('M', 42),
                        NBarDatum('T', 88),
                        NBarDatum('W', 31),
                        NBarDatum('T', 64),
                        NBarDatum('F', 120),
                        NBarDatum('S', 47),
                        NBarDatum('S', 20),
                      ],
                      selected: _bar,
                      onSelect: (i) => setState(() => _bar = i),
                    ),
                    const SizedBox(height: 16),
                    NSegmentedControl(
                      values: const ['Week', 'Month', 'Year'],
                      selected: _range,
                      label: (v) => v,
                      onChanged: (v) => setState(() => _range = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              NCard(
                child: Row(
                  children: [
                    NProgressRing(
                      value: 0.62,
                      size: 64,
                      color: c.success,
                      child: Text('62%', style: NaaliType.number(15, color: c.textPrimary)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trip to Lisbon', style: NaaliType.headline.copyWith(color: c.textPrimary)),
                          const SizedBox(height: 4),
                          Text('€1,240 of €2,000', style: NaaliType.caption.copyWith(color: c.textSecondary)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: c.textTertiary),
                  ],
                ),
              ),
            ]),
          ),
          SliverToBoxAdapter(child: SizedBox(height: pad.bottom + 110)),
        ],
      ),
    );
  }

  Widget _balance(BuildContext context) {
    final c = context.naali;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 28),
      child: Column(
        children: [
          Text('Personal · EUR', style: NaaliType.caption.copyWith(color: c.textSecondary)),
          const SizedBox(height: 10),
          NAmount(NMoney.format(12480.52), size: 52, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          NPillChip(label: 'Accounts', selected: false, onTap: () => _accountsSheet(context)),
        ],
      ),
    );
  }

  Widget _txnRow(BuildContext context, Txn t) {
    final c = context.naali;
    return NListItem(
      leading: t.icon == null ? NAvatar.initials(t.name) : NAvatar.icon(t.icon!),
      title: t.name,
      subtitle: t.when,
      trailingTitle: NMoney.format(t.amount, showPlus: true),
      trailingTitleColor: t.amount > 0 ? c.success : null,
      trailing: t.tag == null ? null : NTag(t.tag!, tone: NTagTone.warning),
      onTap: () => _txnSheet(context, t),
    );
  }

  void _txnSheet(BuildContext context, Txn t) => showNSheet(
        context,
        builder: (ctx) {
          final c = ctx.naali;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              children: [
                t.icon == null ? NAvatar.initials(t.name, size: 64) : NAvatar.icon(t.icon!, size: 64),
                const SizedBox(height: 14),
                Text(t.name, style: NaaliType.title2.copyWith(color: c.textPrimary)),
                const SizedBox(height: 6),
                NAmount(NMoney.format(t.amount, showPlus: true), size: 40, color: t.amount > 0 ? c.success : null),
                const SizedBox(height: 6),
                Text(t.when, style: NaaliType.caption.copyWith(color: c.textSecondary)),
                const SizedBox(height: 20),
                NDetailGroup(rows: [
                  NDetailRow(label: 'Status', value: t.tag ?? 'Completed', valueColor: t.tag == null ? c.success : c.warning),
                  NDetailRow(label: 'Category', value: t.category, onTap: () {}),
                  const NDetailRow(label: 'Card', value: 'Virtual •• 4242'),
                  const NDetailRow(label: 'Reference', value: 'NA-48213-QX'),
                ]),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: NButton.secondary(label: 'Split', icon: Icons.call_split_rounded, onPressed: () {})),
                    const SizedBox(width: 10),
                    Expanded(child: NButton.secondary(label: 'Receipt', icon: Icons.receipt_long_rounded, onPressed: () {})),
                  ],
                ),
              ],
            ),
          );
        },
      );

  void _accountsSheet(BuildContext context) => showNActionSheet<String>(
        context,
        title: 'Accounts',
        actions: const [
          NSheetAction(value: 'eur', label: 'Euro', subtitle: '€12,480.52', icon: Icons.euro_rounded, selected: true),
          NSheetAction(value: 'gbp', label: 'British pound', subtitle: '£840.10', icon: Icons.currency_pound_rounded),
          NSheetAction(value: 'usd', label: 'US dollar', subtitle: '\$1,002.00', icon: Icons.attach_money_rounded),
          NSheetAction(value: 'new', label: 'Add account', icon: Icons.add_rounded),
        ],
      );

  void _detailsSheet(BuildContext context) => showNSheet(
        context,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NSheetHeader('Account details', subtitle: 'Share these to get paid into your EUR account', padding: EdgeInsets.fromLTRB(4, 4, 4, 16)),
              NDetailGroup(rows: [
                const NDetailRow(label: 'Beneficiary', value: 'Alex Morgan'),
                const NDetailRow(label: 'IBAN', value: 'LT12 3250 0012 3456 7890'),
                const NDetailRow(label: 'BIC', value: 'NAALLT21'),
                NDetailRow(
                  label: 'Copy all',
                  value: '',
                  onTap: () {
                    Navigator.pop(ctx);
                    showNToast(context, 'Copied to clipboard', tone: NToastTone.success);
                  },
                ),
              ]),
            ],
          ),
        ),
      );

  void _moreSheet(BuildContext context) async {
    final v = await showNActionSheet<String>(
      context,
      actions: const [
        NSheetAction(value: 'statement', label: 'Statement', icon: Icons.description_outlined),
        NSheetAction(value: 'limits', label: 'Limits', icon: Icons.speed_rounded),
        NSheetAction(value: 'close', label: 'Close account', icon: Icons.delete_outline_rounded, destructive: true),
      ],
    );
    if (v == 'close' && context.mounted) {
      final ok = await showNConfirmSheet(
        context,
        title: 'Close this account?',
        message: 'Your remaining balance of €12,480.52 must be moved first.',
        confirmLabel: 'Close account',
        destructive: true,
        icon: Icons.delete_outline_rounded,
      );
      if (ok && context.mounted) showNToast(context, 'Account closed', tone: NToastTone.danger);
    }
  }

  void _profileSheet(BuildContext context) => showNSheet(
        context,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NListItem(
                leading: const NAvatar.initials('Alex Morgan', size: 52),
                title: 'Alex Morgan',
                subtitle: '@alexm · Premium',
                chevron: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      );
}
