import 'package:flutter/material.dart';

/// Colour tokens. One canvas, solid card surfaces, one accent.
///
/// Read them with `context.naali` (see [NaaliContext]). Components never hard-code
/// colours, so every widget follows the active light/dark palette.
@immutable
class NaaliColors extends ThemeExtension<NaaliColors> {
  const NaaliColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.hairline,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.inverse,
    required this.onInverse,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.violet,
    required this.chartMuted,
    required this.glassFill,
    required this.glassFillStrong,
    required this.glassBorder,
    required this.scrim,
  });

  final Brightness brightness;

  /// Page canvas. Pure black in dark mode, soft grey in light mode.
  final Color background;

  /// Solid card and sheet surface on the canvas.
  final Color surface;

  /// Controls sitting on a card or the canvas: chips, circle buttons, tracks, fields.
  final Color surfaceRaised;
  final Color hairline;

  /// The one accent: primary actions, selection, the data series that matters.
  final Color accent;
  final Color onAccent;

  /// Accent at low opacity for tinted backgrounds (tags, selected rows).
  final Color accentSoft;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Selected pill / inverse button: white on dark, near-black on light.
  final Color inverse;
  final Color onInverse;

  final Color success;
  final Color warning;
  final Color danger;

  /// Category colours for avatars, charts and multi-series data. Not for chrome.
  final Color info;
  final Color violet;

  /// Secondary chart series (previous period, unselected bars).
  final Color chartMuted;

  final Color glassFill;
  final Color glassFillStrong;
  final Color glassBorder;
  final Color scrim;

  bool get isDark => brightness == Brightness.dark;

  /// Palette used for initials avatars and chart categories.
  List<Color> get categorical => [accent, success, violet, warning, danger, info];

  static const dark = NaaliColors(
    brightness: Brightness.dark,
    background: Color(0xFF000000),
    surface: Color(0xFF16171B),
    surfaceRaised: Color(0xFF24252A),
    hairline: Color(0xFF26272C),
    accent: Color(0xFF0A6CFF),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0x290A6CFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8D969E),
    textTertiary: Color(0xFF5E656D),
    inverse: Color(0xFFFFFFFF),
    onInverse: Color(0xFF000000),
    success: Color(0xFF1DC497),
    warning: Color(0xFFF5A524),
    danger: Color(0xFFF0475A),
    info: Color(0xFF3AA0FF),
    violet: Color(0xFFA78BFA),
    chartMuted: Color(0xFF3A3C43),
    glassFill: Color(0x9E16171B),
    glassFillStrong: Color(0xB81C1D21),
    glassBorder: Color(0x1FFFFFFF),
    scrim: Color(0x99000000),
  );

  static const light = NaaliColors(
    brightness: Brightness.light,
    background: Color(0xFFF2F3F5),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFEDEEF1),
    hairline: Color(0xFFE6E7EB),
    accent: Color(0xFF0666EB),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0x1F0666EB),
    textPrimary: Color(0xFF191C1F),
    textSecondary: Color(0xFF717A84),
    textTertiary: Color(0xFFA3AAB2),
    inverse: Color(0xFF191C1F),
    onInverse: Color(0xFFFFFFFF),
    success: Color(0xFF00A87E),
    warning: Color(0xFFE88A00),
    danger: Color(0xFFE23B4A),
    info: Color(0xFF2E8EF0),
    violet: Color(0xFF8B6CF0),
    chartMuted: Color(0xFFD9DCE1),
    glassFill: Color(0xC7FFFFFF),
    glassFillStrong: Color(0xE0FFFFFF),
    glassBorder: Color(0x14000000),
    scrim: Color(0x66000000),
  );

  @override
  NaaliColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? hairline,
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? inverse,
    Color? onInverse,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? violet,
    Color? chartMuted,
    Color? glassFill,
    Color? glassFillStrong,
    Color? glassBorder,
    Color? scrim,
  }) =>
      NaaliColors(
        brightness: brightness,
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceRaised: surfaceRaised ?? this.surfaceRaised,
        hairline: hairline ?? this.hairline,
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
        accentSoft: accentSoft ?? this.accentSoft,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textTertiary: textTertiary ?? this.textTertiary,
        inverse: inverse ?? this.inverse,
        onInverse: onInverse ?? this.onInverse,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
        info: info ?? this.info,
        violet: violet ?? this.violet,
        chartMuted: chartMuted ?? this.chartMuted,
        glassFill: glassFill ?? this.glassFill,
        glassFillStrong: glassFillStrong ?? this.glassFillStrong,
        glassBorder: glassBorder ?? this.glassBorder,
        scrim: scrim ?? this.scrim,
      );

  @override
  NaaliColors lerp(NaaliColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return NaaliColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceRaised: l(surfaceRaised, other.surfaceRaised),
      hairline: l(hairline, other.hairline),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      accentSoft: l(accentSoft, other.accentSoft),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textTertiary: l(textTertiary, other.textTertiary),
      inverse: l(inverse, other.inverse),
      onInverse: l(onInverse, other.onInverse),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      danger: l(danger, other.danger),
      info: l(info, other.info),
      violet: l(violet, other.violet),
      chartMuted: l(chartMuted, other.chartMuted),
      glassFill: l(glassFill, other.glassFill),
      glassFillStrong: l(glassFillStrong, other.glassFillStrong),
      glassBorder: l(glassBorder, other.glassBorder),
      scrim: l(scrim, other.scrim),
    );
  }
}

extension NaaliContext on BuildContext {
  /// Active Naali palette. Falls back to dark when the theme wasn't built by [NaaliTheme].
  NaaliColors get naali => Theme.of(this).extension<NaaliColors>() ?? NaaliColors.dark;
}
