import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Widget app(Widget child) => MaterialApp(theme: NaaliTheme.light(), home: Scaffold(body: Center(child: child)));

  testWidgets('NStepper steps and disables at a limit', (tester) async {
    var n = 1;
    await tester.pumpWidget(app(StatefulBuilder(
      builder: (context, setState) => NStepper(
        value: '$n',
        onDecrement: n > 1 ? () => setState(() => n--) : null,
        onIncrement: () => setState(() => n++),
      ),
    )));
    await tester.tap(find.byTooltip('Decrease'));
    expect(n, 1, reason: 'disabled at the lower limit');
    await tester.tap(find.byTooltip('Increase'));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.byTooltip('Decrease'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('NStepper announces its value, not the custom figure', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(app(NStepper(value: '3 servings', onDecrement: () {}, onIncrement: () {}, child: const Text('3'))));
    expect(tester.getSemantics(find.byType(NStepper)).value, '3 servings');
    expect(find.bySemanticsLabel('3'), findsNothing);
    handle.dispose();
  });
}
