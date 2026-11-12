import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  const items = [
    NNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
    NNavItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Me'),
  ];

  Widget app({required bool scrim, VoidCallback? onBodyTap}) => MaterialApp(
        theme: NaaliTheme.light(),
        home: Scaffold(
          extendBody: true,
          body: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onBodyTap, child: const SizedBox.expand(key: ValueKey('body'))),
          bottomNavigationBar: NNavBar(items: items, index: 0, onTap: (_) {}, scrim: scrim),
        ),
      );

  Iterable<LinearGradient> gradients(WidgetTester tester) => tester
      .widgetList<DecoratedBox>(find.descendant(of: find.byType(NNavBar), matching: find.byType(DecoratedBox)))
      .map((b) => b.decoration)
      .whereType<BoxDecoration>()
      .map((d) => d.gradient)
      .whereType<LinearGradient>();

  testWidgets('NNavBar has no scrim by default', (tester) async {
    await tester.pumpWidget(app(scrim: false));
    expect(gradients(tester), isEmpty);
  });

  testWidgets('NNavBar.scrim fades above the bar and lets taps through its clear top', (tester) async {
    await tester.pumpWidget(app(scrim: false));
    final plain = tester.getSize(find.byType(NNavBar)).height;

    var bodyTaps = 0;
    await tester.pumpWidget(app(scrim: true, onBodyTap: () => bodyTaps++));
    expect(gradients(tester), hasLength(1));
    expect(tester.getSize(find.byType(NNavBar)).height, plain + NaaliSpace.xxl);

    // Just inside the top of the scrim, where it is still clear.
    await tester.tapAt(tester.getTopLeft(find.byType(NNavBar)) + const Offset(10, 4));
    expect(bodyTaps, 1);
  });
}
