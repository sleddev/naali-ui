import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Widget item(int i) => NListItem(key: ValueKey('item$i'), title: 'Row $i');

  Widget app(Widget sliver) => MaterialApp(
        theme: NaaliTheme.light(),
        home: Scaffold(body: CustomScrollView(slivers: [sliver])),
      );

  testWidgets('NSliverListGroup lays out like NListGroup', (tester) async {
    await tester.pumpWidget(app(SliverToBoxAdapter(
      child: NListGroup(title: 'Today', dividers: true, children: [for (var i = 0; i < 3; i++) item(i)]),
    )));
    final eager = [for (var i = 0; i < 3; i++) tester.getRect(find.byKey(ValueKey('item$i')))];
    final eagerTitle = tester.getRect(find.text('Today'));

    await tester.pumpWidget(app(NSliverListGroup.builder(
      title: 'Today',
      dividers: true,
      itemCount: 3,
      itemBuilder: (_, i) => item(i),
    )));
    expect([for (var i = 0; i < 3; i++) tester.getRect(find.byKey(ValueKey('item$i')))], eager);
    expect(tester.getRect(find.text('Today')), eagerTitle);
    expect(find.byType(Divider), findsNWidgets(2));
  });

  testWidgets('NSliverListGroup only builds rows on screen', (tester) async {
    final built = <int>{};
    await tester.pumpWidget(app(NSliverListGroup.builder(
      itemCount: 10000,
      itemBuilder: (_, i) {
        built.add(i);
        return item(i);
      },
    )));
    expect(built.length, lessThan(100));
  });

  testWidgets('NSliverListGroup with no items draws nothing', (tester) async {
    await tester.pumpWidget(app(NSliverListGroup.builder(title: 'Today', itemCount: 0, itemBuilder: (_, i) => item(i))));
    expect(find.text('Today'), findsNothing);
    expect(find.byType(Material).evaluate().length, 1); // just the Scaffold's
  });
}
