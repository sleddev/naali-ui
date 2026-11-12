import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Color thumbColor(WidgetTester tester) {
    // The thumb is the box that fades in under the selection; the track is the one around it.
    final thumb = tester.widget<DecoratedBox>(
      find.descendant(of: find.byType(AnimatedOpacity), matching: find.byType(DecoratedBox)),
    );
    return (thumb.decoration as ShapeDecoration).color!;
  }

  Widget control(ThemeData theme) => MaterialApp(
    theme: theme,
    home: Center(
      child: SizedBox(
        width: 300,
        child: NSegmentedControl<int>(values: const [0, 1], selected: 0, label: (v) => '$v', onChanged: (_) {}),
      ),
    ),
  );

  test('segmentThumb keeps the old colours by default', () {
    expect(NaaliColors.dark.segmentThumb, const Color(0xFF3A3B41));
    expect(NaaliColors.light.segmentThumb, const Color(0xFFFFFFFF));
  });

  test('segmentThumb survives copyWith and lerp', () {
    const warm = Color(0xFF4A3A30);
    final custom = NaaliColors.dark.copyWith(segmentThumb: warm);
    expect(custom.segmentThumb, warm);
    expect(custom.copyWith(accent: const Color(0xFFFF0000)).segmentThumb, warm);
    expect(custom.lerp(NaaliColors.dark, 0).segmentThumb, warm);
  });

  testWidgets('NSegmentedControl paints its thumb from the palette', (tester) async {
    await tester.pumpWidget(control(NaaliTheme.dark()));
    expect(thumbColor(tester), NaaliColors.dark.segmentThumb);

    const warm = Color(0xFF4A3A30);
    final theme = NaaliTheme.dark();
    await tester.pumpWidget(control(theme.copyWith(extensions: [NaaliColors.dark.copyWith(segmentThumb: warm)])));
    // MaterialApp animates between themes.
    await tester.pumpAndSettle();
    expect(thumbColor(tester), warm);
  });
}
