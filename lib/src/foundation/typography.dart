import 'package:flutter/painting.dart';

/// Type scale. Inter for text, the Display cut of Inter for headlines and figures.
///
/// Styles here carry no colour; components and the [ThemeData] text theme add it.
abstract final class NaaliType {
  static const body = 'packages/naali_ui/Inter';
  static const display = 'packages/naali_ui/InterDisplay';

  /// Large page title ("Home", "Cards").
  static const largeTitle =
      TextStyle(fontFamily: display, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.8, height: 1.1);
  static const title1 =
      TextStyle(fontFamily: display, fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.5, height: 1.15);
  static const title2 = TextStyle(fontFamily: display, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2);

  /// Section heading inside a page.
  static const section = TextStyle(fontFamily: display, fontSize: 19, fontWeight: FontWeight.w600, letterSpacing: -0.2);

  /// Title beside the back button on pushed pages.
  static const barTitle = TextStyle(fontFamily: display, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4);

  /// Collapsed page title in the top bar.
  static const navTitle = TextStyle(fontFamily: display, fontSize: 17, fontWeight: FontWeight.w600);

  static const headline = TextStyle(fontFamily: body, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.1);
  static const bodyLarge = TextStyle(fontFamily: body, fontSize: 16, height: 1.4);

  /// List row title.
  static const rowTitle = TextStyle(fontFamily: body, fontSize: 15.5, fontWeight: FontWeight.w500);
  static const bodyText = TextStyle(fontFamily: body, fontSize: 15, height: 1.4);
  static const callout = TextStyle(fontFamily: body, fontSize: 14, height: 1.4);

  /// Secondary caption ("Today, 14:02", "Top speed").
  static const caption = TextStyle(fontFamily: body, fontSize: 13, fontWeight: FontWeight.w500);
  static const footnote = TextStyle(fontFamily: body, fontSize: 12.5);
  static const micro = TextStyle(fontFamily: body, fontSize: 11, fontWeight: FontWeight.w500);

  static const button = TextStyle(fontFamily: body, fontSize: 16, fontWeight: FontWeight.w600);

  /// Tabular display figure, tracked tighter as it grows.
  static TextStyle number(double size, {FontWeight weight = FontWeight.w600, Color? color}) => TextStyle(
        fontFamily: display,
        fontSize: size,
        fontWeight: weight,
        height: 1.05,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: size >= 28 ? -size * 0.025 : -0.2,
      );
}
