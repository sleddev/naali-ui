import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'tokens.dart';
import 'typography.dart';

/// Builds a Material [ThemeData] that renders stock widgets in the Naali language
/// and carries [NaaliColors] as a theme extension.
abstract final class NaaliTheme {
  static ThemeData dark({NaaliColors colors = NaaliColors.dark}) => build(colors);
  static ThemeData light({NaaliColors colors = NaaliColors.light}) => build(colors);

  static ThemeData build(NaaliColors c) {
    final scheme = ColorScheme.fromSeed(seedColor: c.accent, brightness: c.brightness).copyWith(
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.accent,
      onSecondary: c.onAccent,
      secondaryContainer: c.surfaceRaised,
      onSecondaryContainer: c.textPrimary,
      error: c.danger,
      onError: Colors.white,
      surface: c.background,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      outline: c.hairline,
      outlineVariant: c.hairline,
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surfaceRaised,
      surfaceContainerHighest: c.surfaceRaised,
      inverseSurface: c.inverse,
      onInverseSurface: c.onInverse,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: c.brightness,
      fontFamily: NaaliType.body,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      splashFactory: InkRipple.splashFactory,
      highlightColor: c.textPrimary.withValues(alpha: 0.04),
      splashColor: c.textPrimary.withValues(alpha: 0.06),
      extensions: [c],
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      }),
    );

    const pill = StadiumBorder();
    final overlay = c.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: c.textPrimary, displayColor: c.textPrimary).copyWith(
            headlineLarge: NaaliType.largeTitle.copyWith(color: c.textPrimary),
            headlineMedium: NaaliType.title1.copyWith(color: c.textPrimary),
            titleLarge: NaaliType.title2.copyWith(color: c.textPrimary),
            titleMedium: NaaliType.headline.copyWith(color: c.textPrimary),
            bodyLarge: NaaliType.bodyLarge.copyWith(color: c.textPrimary),
            bodyMedium: NaaliType.callout.copyWith(color: c.textSecondary),
            bodySmall: NaaliType.footnote.copyWith(color: c.textSecondary),
            labelLarge: NaaliType.button.copyWith(fontSize: 15),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: c.textPrimary,
        systemOverlayStyle: overlay.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
        titleTextStyle: NaaliType.navTitle.copyWith(color: c.textPrimary),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
        iconColor: c.textSecondary,
        titleTextStyle: NaaliType.rowTitle.copyWith(color: c.textPrimary),
        subtitleTextStyle: NaaliType.caption.copyWith(color: c.textSecondary, fontWeight: FontWeight.w400),
      ),
      dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceRaised,
        hintStyle: TextStyle(color: c.textTertiary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(NaaliRadius.field), borderSide: BorderSide.none),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(NaaliRadius.field), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NaaliRadius.field),
          borderSide: BorderSide(color: c.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NaaliRadius.field),
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NaaliRadius.field),
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
        labelStyle: TextStyle(color: c.textSecondary),
        floatingLabelStyle: TextStyle(color: c.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accent,
        selectionColor: c.accent.withValues(alpha: 0.3),
        selectionHandleColor: c.accent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          shape: pill,
          textStyle: NaaliType.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: pill,
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.surfaceRaised, width: 1.5),
          textStyle: NaaliType.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          shape: pill,
          textStyle: NaaliType.button.copyWith(fontSize: 15),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: c.textPrimary)),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : c.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.accent : c.chartMuted),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.surfaceRaised,
        circularTrackColor: c.surfaceRaised,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surfaceRaised,
        contentTextStyle: NaaliType.callout.copyWith(color: c.textPrimary, fontSize: 14.5),
        actionTextColor: c.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NaaliRadius.field)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.accent,
        thumbColor: Colors.white,
        inactiveTrackColor: c.surfaceRaised,
        overlayColor: c.accent.withValues(alpha: 0.12),
        trackHeight: 4,
      ),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent, elevation: 0),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NaaliRadius.dialog)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: c.inverse, borderRadius: BorderRadius.circular(NaaliRadius.sm)),
        textStyle: NaaliType.caption.copyWith(color: c.onInverse),
      ),
    );
  }
}
