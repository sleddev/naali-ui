import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Widget row(double width, int count) => MaterialApp(
    theme: NaaliTheme.light(),
    home: Center(
      child: SizedBox(
        width: width,
        child: NActionRow(
          actions: [
            for (var i = 0; i < count; i++) NCircleAction(icon: Icons.add_rounded, label: 'Action $i', onTap: () {}),
          ],
        ),
      ),
    ),
  );

  testWidgets('NActionRow scales down instead of overflowing when the actions are too wide', (tester) async {
    // Five 76-wide actions need 380, more than the 300 available.
    await tester.pumpWidget(row(300, 5));
    expect(tester.takeException(), isNull);
    expect(find.byType(FittedBox), findsOneWidget);
    expect(tester.getSize(find.byType(NActionRow)).width, 300);
  });

  testWidgets('NActionRow lays out as a plain row when the actions fit', (tester) async {
    await tester.pumpWidget(row(400, 4));
    expect(tester.takeException(), isNull);
    expect(find.byType(FittedBox), findsNothing);
  });
}
