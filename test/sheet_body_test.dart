import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Future<void> open(WidgetTester tester, Widget body) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NaaliTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showNSheet<void>(context, builder: (_) => body),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('NSheetBody insets its child 20 from the sheet sides, under the header', (tester) async {
    await open(tester, const NSheetBody(title: 'Edit', child: SizedBox(key: ValueKey('child'), height: 40)));
    final child = tester.getRect(find.byKey(const ValueKey('child')));
    final sheet = tester.getRect(find.ancestor(of: find.byKey(const ValueKey('child')), matching: find.byType(ClipRRect)).first);
    expect(child.left - sheet.left, 20);
    expect(sheet.right - child.right, 20);
    expect(child.top, greaterThan(tester.getBottomLeft(find.text('Edit')).dy));
  });

  testWidgets('NSheetBody scrolls long content instead of overflowing', (tester) async {
    await open(
      tester,
      NSheetBody(title: 'Long', child: ListView(shrinkWrap: true, children: [for (var i = 0; i < 60; i++) Text('Row $i')])),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Row 0'), findsOneWidget);
  });
}
