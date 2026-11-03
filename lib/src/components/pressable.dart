import 'package:flutter/widgets.dart';

import '../foundation/tokens.dart';

/// Tap target that shrinks slightly while held, ticks a haptic and calls [onTap].
/// The base of every Naali button; disabled when [onTap] is null.
class NPressable extends StatefulWidget {
  const NPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.scale = 0.96,
    this.haptic = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Scale while pressed; 1 disables the effect.
  final double scale;
  final bool haptic;
  final String? semanticLabel;

  @override
  State<NPressable> createState() => _NPressableState();
}

class _NPressableState extends State<NPressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: () => _set(false),
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.haptic) NaaliHaptics.tap();
                widget.onTap!();
              },
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                _set(false);
                NaaliHaptics.impact();
                widget.onLongPress!();
              },
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: NaaliMotion.fast,
          curve: NaaliMotion.curve,
          child: AnimatedOpacity(
            opacity: !enabled ? 0.4 : (_down ? 0.85 : 1),
            duration: NaaliMotion.fast,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
