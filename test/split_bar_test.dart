import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Future<List<double>> widths(WidgetTester tester, NSplitBar bar, {double width = 300}) async {
    await tester.pumpWidget(MaterialApp(
      theme: NaaliTheme.light(),
      home: Center(child: SizedBox(width: width, child: bar)),
    ));
    final boxes = find.descendant(of: find.byType(NSplitBar), matching: find.byType(ColoredBox));
    return [for (final e in boxes.evaluate()) tester.getSize(find.byWidget(e.widget)).width];
  }

  testWidgets('NSplitBar splits by share and labels both ends', (tester) async {
    final w = await widths(tester, const NSplitBar(leftLabel: 'Left', left: 3, rightLabel: 'Right', right: 1));
    expect(w[0] / (w[0] + w[2]), closeTo(0.75, 0.01));
    expect(tester.getSize(find.descendant(of: find.byType(NSplitBar), matching: find.byType(ColoredBox)).first).height, NaaliSpace.sm);
    expect(find.text('Left'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('NSplitBar halves the bar when both are zero', (tester) async {
    final w = await widths(tester, NSplitBar(leftLabel: 'L', left: 0, rightLabel: 'R', right: 0, format: (v) => '${v}x'));
    expect(w[0], closeTo(w[2], 0.5));
    expect(find.text('0x'), findsNWidgets(2));
  });

  testWidgets('NSplitBar truncates long labels instead of overflowing', (tester) async {
    await widths(
      tester,
      const NSplitBar(leftLabel: 'A very long left label indeed', left: 120, rightLabel: 'An equally long right label', right: 80),
      width: 200,
    );
    expect(tester.takeException(), isNull);
  });
}
