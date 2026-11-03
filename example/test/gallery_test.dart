import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naali_gallery/main.dart';
import 'package:naali_gallery/pages/demos.dart';
import 'package:naali_gallery/pages/transfer_page.dart';
import 'package:naali_ui/naali_ui.dart';

final pages = <String, Widget Function()>{
  'buttons': () => const ButtonsDemo(),
  'actions': () => const ActionsDemo(),
  'lists': () => const ListsDemo(),
  'avatars': () => const AvatarsDemo(),
  'amounts': () => const AmountsDemo(),
  'cards': () => const CardsDemo(),
  'charts': () => const ChartsDemo(),
  'chips': () => const ChipsDemo(),
  'controls': () => const ControlsDemo(),
  'fields': () => const FieldsDemo(),
  'keypad': () => const KeypadDemo(),
  'sheets': () => const SheetsDemo(),
  'progress': () => const ProgressDemo(),
  'banners': () => const BannersDemo(),
  'transfer': () => const TransferPage(title: 'Add money'),
};

void main() {
  for (final dark in [true, false]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('shell renders all tabs ($mode)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
      await tester.pumpWidget(const GalleryApp());
      await tester.pumpAndSettle();
      expect(find.text('Personal · EUR'), findsOneWidget);
      for (final tab in ['Components', 'Tokens', 'Home']) {
        await tester.tap(find.text(tab).last);
        await tester.pumpAndSettle();
      }
    });

    for (final e in pages.entries) {
      testWidgets('${e.key} page renders ($mode)', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          theme: dark ? NaaliTheme.dark() : NaaliTheme.light(),
          home: e.value(),
        ));
        await tester.pump(const Duration(seconds: 1));
        // Scroll to the end so lazily built rows are laid out too.
        final list = find.byType(Scrollable);
        if (list.evaluate().isNotEmpty) {
          await tester.drag(list.first, const Offset(0, -4000));
          await tester.pump(const Duration(seconds: 1));
        }
      });
    }
  }

  test('NMoney formats', () {
    expect(NMoney.format(12480.52), '€12,480.52');
    expect(NMoney.format(-4.2), '-€4.20');
    expect(NMoney.format(42.5, showPlus: true), '+€42.50');
    expect(NMoney.format(2105, trimZeroCents: true), '€2,105');
  });

  test('NAmountController enforces one dot and two decimals', () {
    final c = NAmountController();
    for (final k in ['0', '0', '1', '.', '5', '.', '2', '9']) {
      c.input(k);
    }
    expect(c.value, '1.52');
  });
}
