import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  testWidgets('NBreakdownBar segments fill the bar height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NaaliTheme.light(),
        home: const Center(
          child: SizedBox(
            width: 300,
            child: NBreakdownBar(
              legend: false,
              segments: [NSegment('Food', 3, Colors.red), NSegment('Stay', 1, Colors.blue)],
            ),
          ),
        ),
      ),
    );
    final boxes = find.descendant(of: find.byType(NBreakdownBar), matching: find.byType(ColoredBox));
    expect(boxes, findsNWidgets(3));
    for (final e in boxes.evaluate()) {
      expect(tester.getSize(find.byWidget(e.widget)).height, 12);
    }
  });
}
