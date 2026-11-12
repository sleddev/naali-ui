import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  testWidgets('NSheetAction.leading replaces the icon avatar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NaaliTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showNActionSheet<int>(
              context,
              title: 'Pick',
              actions: const [
                NSheetAction(value: 1, label: 'Emoji', icon: Icons.mood_rounded, leading: Text('🍺')),
                NSheetAction(value: 2, label: 'Icon', icon: Icons.delete_rounded),
              ],
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('🍺'), findsOneWidget);
    expect(find.byIcon(Icons.mood_rounded), findsNothing);
    expect(find.byIcon(Icons.delete_rounded), findsOneWidget);
  });
}
