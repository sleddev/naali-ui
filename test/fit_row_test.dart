import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Widget box(String id, {double w = 50}) => SizedBox(key: ValueKey(id), width: w, height: 20, child: Text(id));

  Future<void> pump(WidgetTester tester, double width, {List<Widget> leading = const [], List<Widget> trailing = const []}) =>
      tester.pumpWidget(MaterialApp(
        home: Center(
          child: SizedBox(
            width: width,
            child: NFitRow(leading: leading, trailing: trailing, spacing: 10, children: [box('a'), box('b'), box('c')]),
          ),
        ),
      ));

  Iterable<String> shown(WidgetTester tester) => ['L', 'a', 'b', 'c', 'T'].where((id) {
        final f = find.byKey(ValueKey(id));
        if (f.evaluate().isEmpty) return false;
        // Hidden children are laid out but never hit.
        return tester.hitTestOnBinding(tester.getCenter(f)).path.any((e) => e.target == tester.renderObject(f));
      });

  testWidgets('NFitRow shows only the children that fit whole', (tester) async {
    await pump(tester, 170);
    expect(shown(tester), ['a', 'b', 'c']);
    await pump(tester, 169);
    expect(shown(tester), ['a', 'b']);
    expect(find.text('c', skipOffstage: false), findsOneWidget);
  });

  testWidgets('NFitRow always keeps leading and trailing', (tester) async {
    await pump(tester, 150, leading: [box('L', w: 40)], trailing: [box('T', w: 40)]);
    expect(shown(tester), ['L', 'a', 'T']);
    await pump(tester, 90, leading: [box('L', w: 40)], trailing: [box('T', w: 40)]);
    expect(shown(tester), ['L', 'T']);
  });

  testWidgets('NFitRow leaves hidden children out of semantics', (tester) async {
    final handle = tester.ensureSemantics();
    Set<String> labels() {
      final out = <String>{};
      void walk(SemanticsNode n) {
        if (n.label.isNotEmpty) out.add(n.label);
        n.visitChildren((c) {
          walk(c);
          return true;
        });
      }

      walk(tester.getSemantics(find.byType(NFitRow)));
      return out;
    }

    await pump(tester, 170);
    expect(labels(), containsAll(['a', 'b', 'c']));
    await pump(tester, 110);
    expect(labels(), containsAll(['a', 'b']));
    expect(labels(), isNot(contains('c')));
    handle.dispose();
  });
}
