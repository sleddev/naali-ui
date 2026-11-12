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
}
