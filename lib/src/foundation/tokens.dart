import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';

/// Corner radii. Cards are generous, controls are pills.
abstract final class NaaliRadius {
  static const xs = 6.0;
  static const sm = 10.0;
  static const field = 14.0;
  static const card = 20.0;
  static const dialog = 24.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}

/// 4pt spacing scale. [page] is the horizontal gutter of every screen.
abstract final class NaaliSpace {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const page = 16.0;
}

abstract final class NaaliMotion {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 350);
  static const curve = Curves.easeOutCubic;

  /// Slight overshoot for things that slide into place (tab lozenges, thumbs).
  static const spring = Curves.easeOutBack;
}

/// Every tappable control gives a light selection tick.
abstract final class NaaliHaptics {
  static void tap() => HapticFeedback.selectionClick();
  static void impact() => HapticFeedback.mediumImpact();
  static void success() => HapticFeedback.lightImpact();
}
