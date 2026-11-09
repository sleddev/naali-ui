import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  testWidgets('showNToast survives the calling route being popped', (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(navigatorKey: navigator, theme: NaaliTheme.light(), home: const SizedBox()));
    navigator.currentState!.push(MaterialPageRoute<void>(
      builder: (context) => Center(
        child: TextButton(onPressed: () => showNToast(context, 'Saved'), child: const Text('Toast')),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Toast'));
    await tester.pump();

    navigator.currentState!.pop();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    // Anything that rebuilds the whole tree (insets, theme, hot reload) rebuilds the toast's overlay entry.
    final reassembled = tester.binding.reassembleApplication();
    await tester.pump();
    await reassembled;
    expect(tester.takeException(), isNull);
    expect(find.text('Saved'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
