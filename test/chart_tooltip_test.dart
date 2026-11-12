import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  late ValueChanged<NChartTip?> show;

  Widget app({double top = 300}) => MaterialApp(
        theme: NaaliTheme.light(),
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.only(top: top),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 200,
                height: 100,
                // A clipping card, as charts usually sit in.
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: NChartTooltip(
                    builder: (context, s) {
                      show = s;
                      return const SizedBox.expand(key: ValueKey('chart'));
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('NChartTooltip floats its tip above the anchor, outside the clip', (tester) async {
    await tester.pumpWidget(app());
    show(const NChartTip(anchor: Offset(100, 10), title: 'Mon', rows: [NChartTipRow('42 km', label: 'Distance')]));
    await tester.pumpAndSettle();
    final chart = tester.getRect(find.byKey(const ValueKey('chart')));
    final tip = tester.getRect(find.ancestor(of: find.text('42 km'), matching: find.byType(Container)).first);
    expect(tip.bottom, lessThan(chart.top + 10), reason: 'above the anchor');
    expect(tip.bottom, lessThan(chart.top), reason: 'drawn past the clipping card');
    expect(find.text('Mon'), findsOneWidget);

    show(null);
    await tester.pumpAndSettle();
    expect(find.text('42 km'), findsNothing);
  });

  testWidgets('NChartTooltip flips below the anchor near the top of the screen', (tester) async {
    await tester.pumpWidget(app(top: 0));
    // Anchor near the chart's top, which sits close to the top of the screen.
    show(const NChartTip(anchor: Offset(100, 4), rows: [NChartTipRow('42 km')]));
    await tester.pumpAndSettle();
    final chart = tester.getRect(find.byKey(const ValueKey('chart')));
    final tip = tester.getRect(find.ancestor(of: find.text('42 km'), matching: find.byType(Container)).first);
    expect(chart.top, lessThan(40));
    expect(tip.top, greaterThan(chart.top + 4), reason: 'no room above, so it sits below the anchor');
  });
}
