import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  testWidgets('NProgressBar track fills the width under loose constraints', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NaaliTheme.light(),
        home: const Center(
          child: SizedBox(
            width: 200,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [NProgressBar(value: 0.25)]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(NProgressBar)).width, 200);
    final bar = find.byType(NProgressBar);
    // The grey track spans the bar; the fill covers a quarter of it.
    expect(tester.getSize(find.descendant(of: bar, matching: find.byType(ColoredBox))).width, 200);
    expect(tester.getSize(find.descendant(of: bar, matching: find.byType(FractionallySizedBox))).width, 50);
  });
}
