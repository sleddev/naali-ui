import 'package:flutter/material.dart';
import 'package:naali_ui/naali_ui.dart';

import '../main.dart';

/// Pushed page listing labelled examples.
class DemoPage extends StatelessWidget {
  const DemoPage({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: NTopBar(title: title, actions: const [ThemeToggle()]),
        body: ListView(
          padding: EdgeInsets.fromLTRB(NaaliSpace.page, 0, NaaliSpace.page, MediaQuery.paddingOf(context).bottom + 32),
          children: children,
        ),
      );
}

/// Labelled example block.
class Demo extends StatelessWidget {
  const Demo(this.title, {super.key, required this.child, this.note});
  final String title;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NSectionHeader(title, padding: const EdgeInsets.fromLTRB(4, 24, 4, 4)),
        if (note != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: Text(note!, style: NaaliType.caption.copyWith(color: c.textSecondary, fontWeight: FontWeight.w400)),
          ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

Widget _wrap(List<Widget> children) => Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: children);

// ─── Buttons ────────────────────────────────────────────────────────────────

class ButtonsDemo extends StatefulWidget {
  const ButtonsDemo({super.key});
  @override
  State<ButtonsDemo> createState() => _ButtonsDemoState();
}

class _ButtonsDemoState extends State<ButtonsDemo> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) => DemoPage(title: 'Buttons', children: [
        Demo('Variants',
            note: 'One primary per screen. Everything else is secondary.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NButton(label: 'Primary', expand: true, onPressed: () {}),
                const SizedBox(height: 10),
                NButton.secondary(label: 'Secondary', expand: true, onPressed: () {}),
                const SizedBox(height: 10),
                NButton(label: 'Inverse', variant: NButtonVariant.inverse, expand: true, onPressed: () {}),
                const SizedBox(height: 10),
                NButton(label: 'Destructive', variant: NButtonVariant.destructive, expand: true, onPressed: () {}),
                const SizedBox(height: 4),
                NButton.tertiary(label: 'Tertiary', onPressed: () {}),
              ],
            )),
        Demo('Sizes',
            child: _wrap([
              NButton(label: 'Large', onPressed: () {}),
              NButton(label: 'Medium', size: NButtonSize.medium, onPressed: () {}),
              NButton(label: 'Small', size: NButtonSize.small, onPressed: () {}),
              NButton.secondary(label: 'Small', size: NButtonSize.small, onPressed: () {}),
            ])),
        Demo('With icon',
            child: _wrap([
              NButton(label: 'Send', icon: Icons.send_rounded, onPressed: () {}),
              NButton.secondary(label: 'Request', icon: Icons.download_rounded, onPressed: () {}),
            ])),
        Demo('States',
            note: 'Tap to see the loading state.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NButton(
                  label: 'Pay €42.00',
                  expand: true,
                  loading: _loading,
                  onPressed: () async {
                    setState(() => _loading = true);
                    await Future<void>.delayed(const Duration(seconds: 2));
                    if (mounted) setState(() => _loading = false);
                  },
                ),
                const SizedBox(height: 10),
                const NButton(label: 'Disabled', expand: true, onPressed: null),
              ],
            )),
        Demo('Side by side',
            child: Row(children: [
              Expanded(child: NButton.secondary(label: 'Decline', onPressed: () {})),
              const SizedBox(width: 10),
              Expanded(child: NButton(label: 'Accept', onPressed: () {})),
            ])),
      ]);
}

// ─── Icon buttons & actions ─────────────────────────────────────────────────

class ActionsDemo extends StatelessWidget {
  const ActionsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return DemoPage(title: 'Icon buttons & actions', children: [
      Demo('Quick-action row',
          note: 'Sits under a balance. Highlight the action the screen is about.',
          child: NCard(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: NActionRow(actions: [
              NCircleAction(icon: Icons.add_rounded, label: 'Add money', onTap: () {}, highlighted: true),
              NCircleAction(icon: Icons.swap_horiz_rounded, label: 'Move', onTap: () {}),
              NCircleAction(icon: Icons.account_balance_rounded, label: 'Details', onTap: () {}),
              NCircleAction(icon: Icons.more_horiz_rounded, label: 'More', onTap: () {}),
            ]),
          )),
      Demo('Icon buttons',
          child: _wrap([
            NIconButton(icon: Icons.arrow_back_rounded, onPressed: () {}),
            NIconButton(icon: Icons.search_rounded, onPressed: () {}),
            NIconButton(icon: Icons.ios_share_rounded, onPressed: () {}, size: 48),
            NIconButton(icon: Icons.favorite_rounded, onPressed: () {}, color: c.danger),
            NIconButton(icon: Icons.check_rounded, onPressed: () {}, background: c.accent, color: c.onAccent),
            const NIconButton(icon: Icons.block_rounded, onPressed: null),
          ])),
      Demo('Glass buttons',
          note: 'Only over imagery or maps.',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(NaaliRadius.card),
            child: Container(
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0A6CFF), Color(0xFFE5267A), Color(0xFFF5A524)]),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NGlassIconButton(icon: Icons.close_rounded, onPressed: () {}),
                  const Spacer(),
                  NGlassIconButton(icon: Icons.layers_rounded, onPressed: () {}),
                  const SizedBox(width: 8),
                  NGlassIconButton(icon: Icons.my_location_rounded, onPressed: () {}),
                ],
              ),
            ),
          )),
      Demo('Link',
          child: Align(alignment: Alignment.centerLeft, child: NLinkButton(label: 'See all', onPressed: () {}))),
    ]);
  }
}

// ─── Lists ──────────────────────────────────────────────────────────────────

class ListsDemo extends StatefulWidget {
  const ListsDemo({super.key});
  @override
  State<ListsDemo> createState() => _ListsDemoState();
}

class _ListsDemoState extends State<ListsDemo> {
  bool _notify = true;
  bool _roundUp = false;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return DemoPage(title: 'Lists', children: [
      Demo('Transactions',
          child: NListGroup(title: 'Today', children: [
            NListItem(
              leading: const NAvatar.icon(Icons.shopping_bag_rounded),
              title: 'Zara',
              subtitle: '14:02 · Card payment',
              trailingTitle: '-€59.90',
              onTap: () {},
            ),
            NListItem(
              leading: const NAvatar.initials('Jonas Weber'),
              title: 'Jonas Weber',
              subtitle: '11:30 · Transfer',
              trailingTitle: '+€25.00',
              trailingTitleColor: c.success,
              trailingSubtitle: 'Dinner',
              onTap: () {},
            ),
            NListItem(
              leading: const NAvatar.icon(Icons.flight_rounded),
              title: 'Ryanair',
              subtitle: '08:15 · Declined',
              trailing: const NTag('Declined', tone: NTagTone.danger),
              onTap: () {},
            ),
          ])),
      Demo('Settings',
          child: NListGroup(children: [
            NListItem(
              leading: NAvatar.icon(Icons.notifications_rounded, color: c.accent),
              title: 'Notifications',
              trailing: NSwitch(value: _notify, onChanged: (v) => setState(() => _notify = v)),
            ),
            NListItem(
              leading: NAvatar.icon(Icons.savings_rounded, color: c.success),
              title: 'Round up spare change',
              subtitle: 'Save the difference on each purchase',
              trailing: NSwitch(value: _roundUp, onChanged: (v) => setState(() => _roundUp = v)),
            ),
            NListItem(
              leading: NAvatar.icon(Icons.lock_rounded, color: c.violet),
              title: 'Privacy & security',
              chevron: true,
              onTap: () {},
            ),
            NListItem(
              leading: NAvatar.icon(Icons.logout_rounded, color: c.danger),
              title: 'Log out',
              destructive: true,
              onTap: () {},
            ),
          ])),
      Demo('Detail rows',
          child: NDetailGroup(rows: [
            const NDetailRow(label: 'Exchange rate', value: '€1 = £0.8541'),
            const NDetailRow(label: 'Fee', value: 'Free'),
            NDetailRow(label: 'You save', value: '€3.20', valueColor: c.success),
            NDetailRow(label: 'Arrives', value: 'Instantly', onTap: () {}),
          ])),
    ]);
  }
}

// ─── Avatars ────────────────────────────────────────────────────────────────

class AvatarsDemo extends StatelessWidget {
  const AvatarsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return DemoPage(title: 'Avatars', children: [
      Demo('Initials',
          note: 'Tint is picked from the name.',
          child: _wrap(const [
            NAvatar.initials('Maya Lindqvist'),
            NAvatar.initials('Jonas Weber'),
            NAvatar.initials('Priya Natarajan'),
            NAvatar.initials('Tomás Ruiz'),
            NAvatar.initials('Ana'),
          ])),
      Demo('Icons',
          child: _wrap([
            const NAvatar.icon(Icons.local_cafe_rounded),
            NAvatar.icon(Icons.savings_rounded, color: c.success),
            NAvatar.icon(Icons.trending_up_rounded, color: c.violet),
            NAvatar.icon(Icons.warning_rounded, color: c.warning),
          ])),
      Demo('Sizes',
          child: _wrap(const [
            NAvatar.initials('Alex Morgan', size: 28),
            NAvatar.initials('Alex Morgan', size: 40),
            NAvatar.initials('Alex Morgan', size: 56),
            NAvatar.initials('Alex Morgan', size: 72),
          ])),
      Demo('Badges',
          child: _wrap([
            NAvatar.initials('Maya Lindqvist', size: 48, badge: NBadgeDot(color: c.success)),
            NAvatar.icon(Icons.shopping_bag_rounded, size: 48, badge: NBadgeDot(color: c.accent, icon: Icons.credit_card_rounded)),
            NAvatar.icon(Icons.euro_rounded, size: 48, badge: NBadgeDot(color: c.danger, icon: Icons.close_rounded)),
          ])),
      Demo('Stack',
          child: Align(
            alignment: Alignment.centerLeft,
            child: NAvatarStack(names: const ['Maya L', 'Jonas W', 'Priya N', 'Tomás R', 'Ana B', 'Kai O']),
          )),
      Demo('Count badge',
          child: _wrap([
            NCountBadge(count: 3, child: NIconButton(icon: Icons.notifications_none_rounded, onPressed: () {})),
            NCountBadge(count: 128, child: NIconButton(icon: Icons.mail_outline_rounded, onPressed: () {})),
          ])),
    ]);
  }
}

// ─── Amounts ────────────────────────────────────────────────────────────────

class AmountsDemo extends StatelessWidget {
  const AmountsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return DemoPage(title: 'Amounts & stats', children: [
      Demo('Balance',
          note: 'Decimals set smaller, like a balance.',
          child: NCard(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(children: [
              Text('Total wealth', style: NaaliType.caption.copyWith(color: c.textSecondary)),
              const SizedBox(height: 8),
              NAmount(NMoney.format(48210.07), size: 48, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const NDeltaChip(text: '€1,204 this month', direction: 1, positiveIsGood: true),
            ]),
          )),
      Demo('Sizes',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NAmount(NMoney.format(1234.5, symbol: '£'), size: 40),
              const SizedBox(height: 8),
              NAmount(NMoney.format(87.25, symbol: '\$'), size: 28),
              const SizedBox(height: 8),
              NAmount(NMoney.format(-12.4), size: 20, color: c.danger),
              const SizedBox(height: 8),
              const NAmount('0.0421', unit: 'BTC', size: 28),
            ],
          )),
      Demo('Stats',
          child: NCard(
            child: Row(children: [
              const Expanded(child: NStatValue(label: 'Income', value: '€3,250')),
              const Expanded(child: NStatValue(label: 'Spent', value: '€1,874')),
              Expanded(child: NStatValue(label: 'Saved', value: '42', unit: '%', color: c.success)),
            ]),
          )),
      Demo('Deltas',
          child: _wrap(const [
            NDeltaChip(text: '12%', direction: 1, positiveIsGood: true),
            NDeltaChip(text: '4%', direction: 1, positiveIsGood: false),
            NDeltaChip(text: '€80 vs last week', direction: -1, positiveIsGood: false),
            NDeltaChip(text: 'Same as usual', direction: 0),
          ])),
    ]);
  }
}

// ─── Cards ──────────────────────────────────────────────────────────────────

class CardsDemo extends StatefulWidget {
  const CardsDemo({super.key});
  @override
  State<CardsDemo> createState() => _CardsDemoState();
}

class _CardsDemoState extends State<CardsDemo> {
  bool _frozen = false;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return DemoPage(title: 'Cards', children: [
      Demo('Payment card',
          child: Column(children: [
            NPaymentCard(finish: NCardFinish.ocean, holder: 'Alex Morgan', frozen: _frozen),
            const SizedBox(height: 16),
            NActionRow(actions: [
              NCircleAction(
                icon: Icons.ac_unit_rounded,
                label: _frozen ? 'Unfreeze' : 'Freeze',
                highlighted: _frozen,
                onTap: () => setState(() => _frozen = !_frozen),
              ),
              NCircleAction(icon: Icons.visibility_rounded, label: 'Details', onTap: () {}),
              NCircleAction(icon: Icons.settings_rounded, label: 'Settings', onTap: () {}),
            ]),
          ])),
      Demo('Finishes',
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.586,
            children: [
              for (final f in NCardFinish.values) NPaymentCard(finish: f, label: f.name[0].toUpperCase() + f.name.substring(1)),
            ],
          )),
      Demo('Surface card',
          note: 'No borders or shadows; hierarchy from spacing and type.',
          child: NCard(
            onTap: () {},
            child: Row(children: [
              NAvatar.icon(Icons.savings_rounded, color: c.success, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Savings vault', style: NaaliType.headline.copyWith(color: c.textPrimary)),
                  const SizedBox(height: 2),
                  Text('2.25% AER · Instant access', style: NaaliType.caption.copyWith(color: c.textSecondary)),
                ]),
              ),
              Text('€8,400', style: NaaliType.number(18, color: c.textPrimary)),
            ]),
          )),
      Demo('Glass panel',
          note: 'Frosted; reserved for chrome floating over content.',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(NaaliRadius.card),
            child: Stack(children: [
              Container(
                height: 170,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1DC497), Color(0xFF0A6CFF), Color(0xFFA78BFA)],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: NGlass(
                  child: Row(children: [
                    const NStatValue(label: 'Speed', value: '48', unit: 'km/h'),
                    const Spacer(),
                    NButton(label: 'Stop', size: NButtonSize.small, variant: NButtonVariant.destructive, onPressed: () {}),
                  ]),
                ),
              ),
            ]),
          )),
    ]);
  }
}

// ─── Charts ─────────────────────────────────────────────────────────────────

class ChartsDemo extends StatefulWidget {
  const ChartsDemo({super.key});
  @override
  State<ChartsDemo> createState() => _ChartsDemoState();
}

class _ChartsDemoState extends State<ChartsDemo> {
  int _sel = 4;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    const months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'];
    const values = [1420.0, 1810.0, 1260.0, 1640.0, 2105.0, 980.0];
    return DemoPage(title: 'Charts', children: [
      Demo('Bar chart',
          note: 'Tap a bar. Selected is accent; the rest stay muted.',
          child: NChartCard(
            title: 'Spent in ${months[_sel]}',
            value: NMoney.format(values[_sel], trimZeroCents: true),
            child: NBarChart(
              data: [for (var i = 0; i < months.length; i++) NBarDatum(months[i], values[i])],
              selected: _sel,
              onSelect: (i) => setState(() => _sel = i),
            ),
          )),
      Demo('Sparkline',
          child: NChartCard(
            title: 'Portfolio',
            value: NMoney.format(18420.10),
            trailing: const NDeltaChip(text: '6.4%', direction: 1, positiveIsGood: true),
            child: NSparkline(values: const [12, 14, 13, 17, 16, 19, 18, 22, 21, 25, 24, 28]),
          )),
      Demo('Breakdown',
          child: NChartCard(
            title: 'By category',
            value: NMoney.format(1873.90),
            child: NBreakdownBar(
              format: (v) => NMoney.format(v, decimals: 0),
              segments: [
                NSegment('Groceries', 520, c.accent),
                NSegment('Eating out', 410, c.warning),
                NSegment('Transport', 290, c.success),
                NSegment('Shopping', 380, c.violet),
                NSegment('Other', 274, c.chartMuted),
              ],
            ),
          )),
    ]);
  }
}

// ─── Chips ──────────────────────────────────────────────────────────────────

class ChipsDemo extends StatefulWidget {
  const ChipsDemo({super.key});
  @override
  State<ChipsDemo> createState() => _ChipsDemoState();
}

class _ChipsDemoState extends State<ChipsDemo> {
  String _tab = 'All';
  String _seg = 'Expenses';
  final _filters = <String>{'Card'};

  @override
  Widget build(BuildContext context) => DemoPage(title: 'Chips, tabs & tags', children: [
        Demo('Pill tabs',
            note: 'Single select. Selected pills invert.',
            child: NPillTabs(
              values: const ['All', 'Income', 'Spending', 'Transfers', 'Refunds'],
              selected: _tab,
              label: (v) => v,
              onChanged: (v) => setState(() => _tab = v),
            )),
        Demo('Filter chips',
            note: 'Multi select, with icons.',
            child: _wrap([
              for (final (l, i) in const [
                ('Card', Icons.credit_card_rounded),
                ('Transfer', Icons.swap_horiz_rounded),
                ('ATM', Icons.local_atm_rounded),
                ('Online', Icons.language_rounded),
              ])
                NPillChip(
                  label: l,
                  icon: i,
                  selected: _filters.contains(l),
                  onTap: () => setState(() => _filters.contains(l) ? _filters.remove(l) : _filters.add(l)),
                ),
            ])),
        Demo('Segmented control',
            child: NSegmentedControl(
              values: const ['Expenses', 'Income', 'Net'],
              selected: _seg,
              label: (v) => v,
              onChanged: (v) => setState(() => _seg = v),
            )),
        Demo('Tags',
            child: _wrap(const [
              NTag('Neutral'),
              NTag('New', tone: NTagTone.accent),
              NTag('Completed', tone: NTagTone.success, icon: Icons.check_rounded),
              NTag('Pending', tone: NTagTone.warning, icon: Icons.schedule_rounded),
              NTag('Declined', tone: NTagTone.danger),
            ])),
      ]);
}

// ─── Controls ───────────────────────────────────────────────────────────────

class ControlsDemo extends StatefulWidget {
  const ControlsDemo({super.key});
  @override
  State<ControlsDemo> createState() => _ControlsDemoState();
}

class _ControlsDemoState extends State<ControlsDemo> {
  bool _a = true, _b = false;
  bool _c1 = true, _c2 = false;
  String _plan = 'Premium';
  double _limit = 1500;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return DemoPage(title: 'Selection controls', children: [
      Demo('Switch',
          child: _wrap([
            NSwitch(value: _a, onChanged: (v) => setState(() => _a = v)),
            NSwitch(value: _b, onChanged: (v) => setState(() => _b = v)),
            const NSwitch(value: true, onChanged: null),
          ])),
      Demo('Checkbox',
          child: NListGroup(dividerIndent: 16, children: [
            NListItem(
              title: 'I accept the terms',
              trailing: NCheckbox(value: _c1, onChanged: (v) => setState(() => _c1 = v)),
              onTap: () => setState(() => _c1 = !_c1),
            ),
            NListItem(
              title: 'Send me product updates',
              trailing: NCheckbox(value: _c2, onChanged: (v) => setState(() => _c2 = v)),
              onTap: () => setState(() => _c2 = !_c2),
            ),
          ])),
      Demo('Radio',
          child: NListGroup(children: [
            for (final (p, price, color) in [
              ('Standard', 'Free', c.textSecondary),
              ('Premium', '€7.99/mo', c.accent),
              ('Metal', '€15.99/mo', c.violet),
            ])
              NListItem(
                leading: NAvatar.icon(Icons.workspace_premium_rounded, color: color),
                title: p,
                subtitle: price,
                trailing: NRadio(value: p, groupValue: _plan, onChanged: (v) => setState(() => _plan = v)),
                onTap: () => setState(() => _plan = p),
              ),
          ])),
      Demo('Slider',
          child: NCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              NStatValue(label: 'Monthly spending limit', value: NMoney.format(_limit, decimals: 0)),
              Slider(value: _limit, min: 100, max: 5000, divisions: 49, onChanged: (v) => setState(() => _limit = v)),
            ]),
          )),
      Demo('Page dots', child: const Center(child: NPageDots(count: 4, index: 1))),
    ]);
  }
}

// ─── Fields ─────────────────────────────────────────────────────────────────

class FieldsDemo extends StatefulWidget {
  const FieldsDemo({super.key});
  @override
  State<FieldsDemo> createState() => _FieldsDemoState();
}

class _FieldsDemoState extends State<FieldsDemo> {
  final _iban = TextEditingController(text: 'LT12 3250');
  bool _hide = true;

  @override
  void dispose() {
    _iban.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return DemoPage(title: 'Text fields', children: [
      Demo('Search', child: NSearchField(hint: 'Search transactions', onChanged: (_) {})),
      Demo('Filled field',
          child: Column(children: [
            const NTextField(label: 'Full name', prefixIcon: Icons.person_outline_rounded),
            const SizedBox(height: 12),
            const NTextField(label: 'Email', hint: 'you@example.com', keyboardType: TextInputType.emailAddress, helper: 'We\'ll send a confirmation link.'),
            const SizedBox(height: 12),
            NTextField(
              label: 'Password',
              obscure: _hide,
              suffix: IconButton(
                icon: Icon(_hide ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: c.textSecondary),
                onPressed: () => setState(() => _hide = !_hide),
              ),
            ),
          ])),
      Demo('Error', child: NTextField(controller: _iban, label: 'IBAN', error: 'This IBAN looks too short')),
      Demo('Disabled', child: const NTextField(label: 'Account number', enabled: false)),
      Demo('Multiline', child: const NTextField(label: 'Note to recipient', maxLines: 3)),
    ]);
  }
}

// ─── Keypad ─────────────────────────────────────────────────────────────────

class KeypadDemo extends StatefulWidget {
  const KeypadDemo({super.key});
  @override
  State<KeypadDemo> createState() => _KeypadDemoState();
}

class _KeypadDemoState extends State<KeypadDemo> {
  final _amount = NAmountController();
  String _pin = '';
  bool _pinError = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _pinKey(String k) {
    if (_pin.length >= 4) return;
    setState(() {
      _pinError = false;
      _pin += k;
    });
    if (_pin.length == 4) {
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        final ok = _pin == '1234';
        if (ok) {
          showNToast(context, 'Unlocked', tone: NToastTone.success);
        } else {
          NaaliHaptics.impact();
        }
        setState(() {
          _pinError = !ok;
          _pin = '';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return DemoPage(title: 'Keypad & PIN', children: [
      Demo('Amount entry',
          child: NCard(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: ValueListenableBuilder(
              valueListenable: _amount,
              builder: (context, text, _) => Column(children: [
                NAmountDisplay(text: text, symbol: '£', caption: 'Exchange from €'),
                const SizedBox(height: 12),
                NNumberPad(onKey: _amount.input, onBackspace: _amount.backspace, keyHeight: 54),
              ]),
            ),
          )),
      Demo('Passcode',
          note: 'Try 1234.',
          child: NCard(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(children: [
              Text(_pinError ? 'Wrong passcode' : 'Enter passcode',
                  style: NaaliType.headline.copyWith(color: _pinError ? c.danger : c.textPrimary)),
              const SizedBox(height: 20),
              NPinDots(length: 4, filled: _pin.length, error: _pinError),
              const SizedBox(height: 16),
              NNumberPad(
                showDecimal: false,
                keyHeight: 54,
                onKey: _pinKey,
                onBackspace: () => setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1)),
              ),
            ]),
          )),
    ]);
  }
}

// ─── Sheets ─────────────────────────────────────────────────────────────────

class SheetsDemo extends StatelessWidget {
  const SheetsDemo({super.key});

  @override
  Widget build(BuildContext context) => DemoPage(title: 'Sheets & toasts', children: [
        Demo('Bottom sheets',
            note: 'Dialogs in Naali are sheets.',
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              NButton.secondary(
                label: 'Action sheet',
                onPressed: () async {
                  final v = await showNActionSheet<String>(context, title: 'Share receipt', actions: const [
                    NSheetAction(value: 'pdf', label: 'Download PDF', icon: Icons.picture_as_pdf_rounded),
                    NSheetAction(value: 'email', label: 'Email', icon: Icons.mail_outline_rounded),
                    NSheetAction(value: 'link', label: 'Copy link', icon: Icons.link_rounded, selected: true),
                  ]);
                  if (v != null && context.mounted) showNToast(context, 'Chose "$v"');
                },
              ),
              const SizedBox(height: 10),
              NButton.secondary(
                label: 'Confirm sheet',
                onPressed: () async {
                  final ok = await showNConfirmSheet(
                    context,
                    title: 'Send €250.00 to Maya?',
                    message: 'Maya Lindqvist will receive the money instantly.',
                    confirmLabel: 'Send',
                    icon: Icons.send_rounded,
                  );
                  if (context.mounted) showNToast(context, ok ? 'Sent' : 'Cancelled', tone: ok ? NToastTone.success : NToastTone.neutral);
                },
              ),
              const SizedBox(height: 10),
              NButton.secondary(
                label: 'Destructive confirm',
                onPressed: () => showNConfirmSheet(
                  context,
                  title: 'Terminate card?',
                  message: 'This can\'t be undone. Subscriptions on this card will fail.',
                  confirmLabel: 'Terminate',
                  destructive: true,
                  icon: Icons.credit_card_off_rounded,
                ),
              ),
              const SizedBox(height: 10),
              NButton.secondary(
                label: 'Custom sheet with form',
                onPressed: () => showNSheet(
                  context,
                  builder: (ctx) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const NSheetHeader('Rename vault', padding: EdgeInsets.fromLTRB(4, 0, 4, 16)),
                      const NTextField(label: 'Name', autofocus: true),
                      const SizedBox(height: 20),
                      NButton(label: 'Save', onPressed: () => Navigator.pop(ctx)),
                    ]),
                  ),
                ),
              ),
            ])),
        Demo('Toasts',
            child: _wrap([
              NButton(label: 'Neutral', size: NButtonSize.medium, variant: NButtonVariant.secondary, onPressed: () => showNToast(context, 'Card details copied')),
              NButton(label: 'Success', size: NButtonSize.medium, variant: NButtonVariant.secondary, onPressed: () => showNToast(context, '€42.50 received from Maya', tone: NToastTone.success)),
              NButton(label: 'Error', size: NButtonSize.medium, variant: NButtonVariant.secondary, onPressed: () => showNToast(context, 'Payment declined: insufficient funds', tone: NToastTone.danger)),
            ])),
      ]);
}

// ─── Progress ───────────────────────────────────────────────────────────────

class ProgressDemo extends StatefulWidget {
  const ProgressDemo({super.key});
  @override
  State<ProgressDemo> createState() => _ProgressDemoState();
}

class _ProgressDemoState extends State<ProgressDemo> {
  double _v = 0.35;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return DemoPage(title: 'Progress & loading', children: [
      Demo('Budget bars',
          note: 'Tap the card to change values.',
          child: NCard(
            onTap: () => setState(() => _v = _v > 0.8 ? 0.2 : _v + 0.25),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final (label, f, color) in [
                ('Groceries', _v, c.accent),
                ('Eating out', (_v + 0.3).clamp(0.0, 1.0), c.warning),
                ('Transport', (1.1 - _v).clamp(0.0, 1.0), c.danger),
              ]) ...[
                Row(children: [
                  Expanded(child: Text(label, style: NaaliType.rowTitle.copyWith(color: c.textPrimary))),
                  Text('${(f * 100).round()}%', style: NaaliType.caption.copyWith(color: c.textSecondary)),
                ]),
                const SizedBox(height: 8),
                NProgressBar(value: f, color: color),
                const SizedBox(height: 16),
              ],
            ]),
          )),
      Demo('Rings',
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            NProgressRing(value: _v, child: Text('${(_v * 100).round()}%', style: NaaliType.number(16, color: c.textPrimary))),
            NProgressRing(value: 0.8, color: c.success, child: Icon(Icons.savings_rounded, color: c.success)),
            NProgressRing(value: 1, size: 56, stroke: 5, color: c.violet, child: Icon(Icons.check_rounded, color: c.violet)),
          ])),
      Demo('Spinner', child: const Center(child: SizedBox.square(dimension: 28, child: CircularProgressIndicator(strokeWidth: 3)))),
      Demo('Skeleton', note: 'Shimmering placeholder while rows load.', child: const NSkeletonList(rows: 3)),
    ]);
  }
}

// ─── Banners ────────────────────────────────────────────────────────────────

class BannersDemo extends StatelessWidget {
  const BannersDemo({super.key});

  @override
  Widget build(BuildContext context) => DemoPage(title: 'Banners & empty states', children: [
        Demo('Banners',
            child: Column(children: [
              NBanner(title: 'Verify your identity', message: 'Upload a photo ID to unlock higher limits.', actionLabel: 'Verify now', onAction: () {}, onClose: () {}),
              const SizedBox(height: 10),
              const NBanner(tone: NBannerTone.success, title: 'Card delivered', message: 'Activate it by making a chip & PIN payment.'),
              const SizedBox(height: 10),
              const NBanner(tone: NBannerTone.warning, title: 'Low balance', message: 'Your EUR balance is below €50.'),
              const SizedBox(height: 10),
              NBanner(tone: NBannerTone.danger, title: 'Payment failed', message: 'Netflix couldn\'t charge your card.', actionLabel: 'Retry', onAction: () {}),
            ])),
        Demo('Empty state',
            child: NCard(
              child: NEmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No transactions yet',
                message: 'Add money to your account to start spending.',
                action: NButton(label: 'Add money', size: NButtonSize.medium, icon: Icons.add_rounded, onPressed: () {}),
              ),
            )),
      ]);
}
