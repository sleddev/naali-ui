import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Future<({double sheetTop, double contentTop})> open(WidgetTester tester, {required bool over}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NaaliTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showNSheet<void>(
              context,
              grabberOverContent: over,
              builder: (_) => const SizedBox(key: ValueKey('content'), height: 200, width: double.infinity),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final sheet = find.ancestor(of: find.byKey(const ValueKey('content')), matching: find.byType(ClipRRect));
    return (
      sheetTop: tester.getTopLeft(sheet.first).dy,
      contentTop: tester.getTopLeft(find.byKey(const ValueKey('content'))).dy,
    );
  }

  testWidgets('showNSheet puts content below the grabber strip by default', (tester) async {
    final r = await open(tester, over: false);
    expect(r.contentTop - r.sheetTop, nSheetGrabberExtent);
  });

  testWidgets('showNSheet(grabberOverContent) starts content at the top edge', (tester) async {
    final r = await open(tester, over: true);
    expect(r.contentTop, r.sheetTop);
  });
}
