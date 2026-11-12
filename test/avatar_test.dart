import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  BoxDecoration disc(WidgetTester tester) => tester
      .widget<Container>(find.descendant(of: find.byType(NAvatar), matching: find.byType(Container)).first)
      .decoration! as BoxDecoration;

  Widget app(Widget child) => MaterialApp(theme: NaaliTheme.light(), home: Center(child: child));

  testWidgets('NAvatar.emoji shows the emoji on the neutral disc', (tester) async {
    await tester.pumpWidget(app(const NAvatar.emoji('🔥', size: 48)));
    expect(find.text('🔥'), findsOneWidget);
    expect(disc(tester).color, NaaliColors.light.surfaceRaised);
    expect(tester.getSize(find.byType(NAvatar)), const Size(48, 48));
  });

  testWidgets('NAvatar.emoji takes a soft tint like the other avatars', (tester) async {
    const tint = Color(0xFFE88A00);
    await tester.pumpWidget(app(const NAvatar.emoji('🔥', color: tint)));
    expect(disc(tester).color, tint.withValues(alpha: 0.14));
  });
}
