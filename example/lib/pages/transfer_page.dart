import 'package:flutter/material.dart';
import 'package:naali_ui/naali_ui.dart';

/// Amount entry flow: big amount, source account pill, keypad, primary button.
class TransferPage extends StatefulWidget {
  const TransferPage({super.key, required this.title});
  final String title;

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _amount = NAmountController();
  bool _sending = false;
  static const _balance = 12480.52;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    NaaliHaptics.success();
    showNToast(context, '${NMoney.format(_amount.amount)} added', tone: NToastTone.success);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NTopBar(title: widget.title),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder(
          valueListenable: _amount,
          builder: (context, text, _) {
            final over = _amount.amount > _balance;
            return Column(
              children: [
                const Spacer(),
                NAmountDisplay(
                  text: text,
                  caption: over ? 'Exceeds your balance' : 'Balance: ${NMoney.format(_balance)}',
                  error: over,
                ),
                const SizedBox(height: 20),
                NPillChip(label: 'From  Euro · EUR', icon: Icons.euro_rounded, selected: false, onTap: () {}),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: NNumberPad(onKey: _amount.input, onBackspace: _amount.backspace),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: NButton(
                    label: 'Continue',
                    expand: true,
                    loading: _sending,
                    onPressed: _amount.amount > 0 && !over ? _send : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
