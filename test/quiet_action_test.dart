import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Widget app(Widget child) => MaterialApp(theme: NaaliTheme.light(), home: Scaffold(body: Center(child: child)));

  Color? iconColor(WidgetTester tester) => tester.widget<Icon>(find.byType(Icon)).color;

  testWidgets('NQuietAction is grey at rest and accent when active', (tester) async {
    var taps = 0;
    await tester.pumpWidget(app(NQuietAction(icon: Icons.schedule, label: 'Now', onTap: () => taps++)));
    expect(iconColor(tester), NaaliColors.light.textSecondary);
    await tester.tap(find.text('Now'));
    expect(taps, 1);

    await tester.pumpWidget(app(NQuietAction(icon: Icons.schedule, label: 'Now', onTap: () {}, active: true)));
    expect(iconColor(tester), NaaliColors.light.accent);
  });

  testWidgets('NQuietAction announces its label once, as a selected button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(app(NQuietAction(icon: Icons.notes, label: 'Note', onTap: () {}, active: true)));
    expect(
      tester.getSemantics(find.byType(NQuietAction)),
      matchesSemantics(label: 'Note', isButton: true, isSelected: true, hasSelectedState: true, isEnabled: true, hasEnabledState: true, hasTapAction: true),
    );
    handle.dispose();
  });
}
