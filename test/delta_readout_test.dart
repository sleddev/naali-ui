import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Future<Color?> colorOf(WidgetTester tester, NDeltaReadout readout) async {
    await tester.pumpWidget(MaterialApp(theme: NaaliTheme.light(), home: Center(child: readout)));
    await tester.pumpAndSettle();
    return tester.widget<AnimatedDefaultTextStyle>(find.byType(AnimatedDefaultTextStyle)).style.color;
  }

  testWidgets('NDeltaReadout colours by direction', (tester) async {
    const c = NaaliColors.light;
    expect(await colorOf(tester, const NDeltaReadout(text: '−0.42', direction: -1, positiveIsGood: false)), c.success);
    expect(await colorOf(tester, const NDeltaReadout(text: '+1.07', direction: 1, positiveIsGood: false)), c.danger);
    expect(await colorOf(tester, const NDeltaReadout(text: '0.00', direction: 0, positiveIsGood: false)), c.textSecondary);
    expect(await colorOf(tester, const NDeltaReadout(text: '+3', direction: 1)), c.textSecondary);
  });

  testWidgets('NDeltaReadout shows the placeholder while text is null', (tester) async {
    final color = await colorOf(tester, const NDeltaReadout(text: null, direction: 1, positiveIsGood: true));
    expect(find.text('—'), findsOneWidget);
    expect(color, NaaliColors.light.textSecondary);
  });
}
