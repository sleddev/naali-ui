# Naali UI

A Flutter UI framework in the Revolut design language: pure-black (or soft grey) canvas, solid 20px cards with no
borders or shadows, one blue accent, pill controls that invert when selected, Inter / Inter Display type with
balance-style figures, sheets instead of dialogs, and frosted glass only for chrome floating over content.
The tokens are derived from the `roadss` app. Ships light and dark palettes.

## Use

```yaml
dependencies:
  naali_ui:
    path: ../naali-ui
```

```dart
MaterialApp(theme: NaaliTheme.light(), darkTheme: NaaliTheme.dark(), ...);

final c = context.naali;          // colour tokens of the active theme
Text('Hi', style: NaaliType.title2.copyWith(color: c.textPrimary));
```

Stock Material widgets (Slider, TextField, ListTile, SnackBar…) are themed too.

## Components

| Area | Widgets |
|---|---|
| Foundation | `NaaliColors` (ThemeExtension), `NaaliType`, `NaaliRadius`, `NaaliSpace`, `NaaliMotion`, `NaaliHaptics`, `NaaliTheme` |
| Actions | `NButton` (primary/secondary/inverse/tertiary/destructive × large/medium/small, loading), `NIconButton`, `NCircleAction`, `NActionRow`, `NLinkButton`, `NPressable` |
| Surfaces | `NCard`, `NGlass`, `NGlassIconButton`, `NPaymentCard` |
| Lists | `NListItem`, `NListGroup`, `NDetailRow`, `NDetailGroup`, `NSectionHeader` |
| Identity | `NAvatar` (initials/icon/image + badge), `NAvatarStack`, `NBadgeDot`, `NCountBadge` |
| Figures | `NAmount`, `NStatValue`, `NDeltaChip`, `NMoney.format` |
| Selection | `NPillChip`, `NPillTabs`, `NSegmentedControl`, `NTag`, `NSwitch`, `NCheckbox`, `NRadio`, `NPageDots` |
| Input | `NTextField`, `NSearchField`, `NAmountDisplay` + `NAmountController` + `NNumberPad`, `NPinDots` |
| Feedback | `showNSheet`, `showNConfirmSheet`, `showNActionSheet`, `showNToast`, `NBanner`, `NEmptyState`, `NProgressBar`, `NProgressRing`, `NSkeleton`/`NShimmer`/`NSkeletonList` |
| Navigation | `NNavBar` (floating glass), `NCollapsingPage` (large title), `NTopBar`, `NTabReselect` |
| Charts | `NChartCard`, `NBarChart`, `NSparkline`, `NBreakdownBar` |

## Gallery

```sh
cd example
flutter run
flutter test     # renders every demo page in light and dark
```
