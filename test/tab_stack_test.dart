import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

class _Counter extends StatefulWidget {
  const _Counter(this.name);
  final String name;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  var _taps = 0;

  @override
  Widget build(BuildContext context) => Center(
        child: TextButton(onPressed: () => setState(() => _taps++), child: Text('${widget.name} $_taps')),
      );
}

void main() {
  Widget stack(int index, {bool reduceMotion = false}) => MaterialApp(
        theme: NaaliTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: NTabStack(index: index, children: const [_Counter('a'), _Counter('b')]),
        ),
      );

  testWidgets('NTabStack keeps tab state across switches', (tester) async {
    await tester.pumpWidget(stack(0));
    await tester.tap(find.text('a 0'));
    await tester.pump();
    expect(find.text('a 1'), findsOneWidget);

    await tester.pumpWidget(stack(1));
    await tester.pumpAndSettle();
    expect(find.text('a 1'), findsNothing); // offstage once the fade is over
    expect(find.text('b 0'), findsOneWidget);

    await tester.pumpWidget(stack(0));
    await tester.pumpAndSettle();
    expect(find.text('a 1'), findsOneWidget);
  });

  testWidgets('NTabStack fades through, with only the new tab taking taps', (tester) async {
    await tester.pumpWidget(stack(0));
    await tester.pumpWidget(stack(1));
    await tester.pump(const Duration(milliseconds: 50));
    // Mid-switch both tabs are on stage.
    expect(find.text('a 0'), findsOneWidget);
    expect(find.text('b 0'), findsOneWidget);

    await tester.tap(find.text('b 0'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('b 1'), findsOneWidget);
  });

  testWidgets('NTabStack switches instantly with reduced motion', (tester) async {
    await tester.pumpWidget(stack(0, reduceMotion: true));
    await tester.pumpWidget(stack(1, reduceMotion: true));
    await tester.pump();
    expect(find.text('a 0'), findsNothing);
    expect(find.text('b 0'), findsOneWidget);
  });
}
