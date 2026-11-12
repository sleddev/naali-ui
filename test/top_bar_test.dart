import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

void main() {
  testWidgets('NTopBar.contentInset is the same above the Scaffold and inside its body', (tester) async {
    double? outside;
    double? inside;
    await tester.pumpWidget(
      MaterialApp(
        theme: NaaliTheme.light(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 800),
            padding: EdgeInsets.only(top: 24),
            viewPadding: EdgeInsets.only(top: 24),
          ),
          child: Builder(
            builder: (context) {
              outside = NTopBar.contentInset(context);
              return Scaffold(
                extendBodyBehindAppBar: true,
                appBar: const NTopBar(title: 'Title'),
                body: Builder(
                  builder: (context) {
                    inside = NTopBar.contentInset(context);
                    return const SizedBox.expand();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    final bar = const NTopBar().preferredSize.height;
    expect(outside, 24 + bar);
    expect(inside, 24 + bar);
  });

  testWidgets('NTopBar.bottom sits under the title row and counts toward its height', (tester) async {
    const bottom = PreferredSize(
      preferredSize: Size.fromHeight(52),
      child: SizedBox(key: ValueKey('bottom'), height: 52, width: double.infinity),
    );
    final plain = const NTopBar().preferredSize.height;
    expect(const NTopBar(bottom: bottom).preferredSize.height, plain + 52);

    double? inset;
    await tester.pumpWidget(
      MaterialApp(
        theme: NaaliTheme.light(),
        home: Builder(
          builder: (context) {
            inset = NTopBar.contentInset(context, bottom: bottom);
            return const Scaffold(
              extendBodyBehindAppBar: true,
              appBar: NTopBar(title: 'Food', bottom: bottom),
              body: SizedBox.expand(),
            );
          },
        ),
      ),
    );
    final title = tester.getBottomLeft(find.text('Food')).dy;
    final row = tester.getRect(find.byKey(const ValueKey('bottom')));
    expect(row.top, greaterThanOrEqualTo(title));
    expect(row.bottom, inset);
  });
}
