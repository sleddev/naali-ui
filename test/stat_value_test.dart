import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  Widget tile({int labelMaxLines = 1}) => MaterialApp(
        theme: NaaliTheme.light(),
        home: Center(
          child: SizedBox(
            width: 100,
            child: NStatValue(label: 'Current streak', value: '12', labelMaxLines: labelMaxLines),
          ),
        ),
      );

  RenderParagraph label(WidgetTester tester) => tester.renderObject<RenderParagraph>(find.text('Current streak'));

  testWidgets('NStatValue.labelMaxLines lets a long label wrap instead of truncating', (tester) async {
    await tester.pumpWidget(tile());
    expect(label(tester).didExceedMaxLines, isTrue, reason: 'one line by default, so it truncates');
    final oneLine = label(tester).size.height;

    await tester.pumpWidget(tile(labelMaxLines: 2));
    expect(label(tester).didExceedMaxLines, isFalse);
    expect(label(tester).size.height, greaterThan(oneLine * 1.5));
  });
}
