import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Widget app(Widget child, {bool reduceMotion = false}) => MaterialApp(
    theme: NaaliTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Center(child: SizedBox(width: 300, child: child)),
    ),
  );

  testWidgets('NSegmentBar lays out equal segments with captions', (tester) async {
    await tester.pumpWidget(app(const NSegmentBar(
      colors: [Colors.green, Colors.red, null],
      activeIndex: 2,
      labels: ['L1', 'L2', 'L3'],
    )));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('L3'), findsOneWidget);
    final widths = [for (final t in ['L1', 'L2', 'L3']) tester.getSize(find.ancestor(of: find.text(t), matching: find.byType(Column)).first).width];
    expect(widths.toSet().length, 1);
    expect(tester.hasRunningAnimations, isTrue, reason: 'the pending active segment pulses');
  });

  testWidgets('NSegmentBar does not pulse with reduced motion or once the step is done', (tester) async {
    await tester.pumpWidget(app(const NSegmentBar(colors: [Colors.green, null], activeIndex: 1), reduceMotion: true));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(app(const NSegmentBar(colors: [Colors.green, Colors.green], activeIndex: 1)));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });
}
