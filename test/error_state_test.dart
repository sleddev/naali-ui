import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Widget app(Widget child) => MaterialApp(theme: NaaliTheme.light(), home: Center(child: child));

  testWidgets('NErrorState shows the message and retries', (tester) async {
    var retries = 0;
    await tester.pumpWidget(app(NErrorState(message: 'No connection.', onRetry: () => retries++)));
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('No connection.'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('NErrorState has no button without onRetry', (tester) async {
    await tester.pumpWidget(app(const NErrorState(message: 'Gone.', title: "Couldn't load this")));
    expect(find.text("Couldn't load this"), findsOneWidget);
    expect(find.byType(NButton), findsNothing);
  });
}
