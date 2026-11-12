import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_ui/naali_ui.dart';

@immutable
class _AppExtension extends ThemeExtension<_AppExtension> {
  const _AppExtension();
  @override
  _AppExtension copyWith() => this;
  @override
  _AppExtension lerp(_AppExtension? other, double t) => this;
}

void main() {
  testWidgets('NOnSheet lifts surfaces one step and keeps other theme extensions', (tester) async {
    late NaaliColors lifted;
    late ThemeData theme;
    final base = NaaliTheme.dark();
    await tester.pumpWidget(
      MaterialApp(
        theme: base.copyWith(extensions: [...base.extensions.values, const _AppExtension()]),
        home: NOnSheet(
          child: Builder(
            builder: (context) {
              lifted = context.naali;
              theme = Theme.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(lifted.surface, NaaliColors.dark.surfaceRaised);
    expect(lifted.surfaceRaised, NaaliColors.dark.chartMuted);
    expect(lifted.accent, NaaliColors.dark.accent);
    // The thumb stays distinct from the lifted track.
    expect(lifted.segmentThumb, isNot(NaaliColors.dark.segmentThumb));
    expect(theme.extension<_AppExtension>(), isNotNull);
  });
}
