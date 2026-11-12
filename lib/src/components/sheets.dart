import 'dart:async';

import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'avatar.dart';
import 'buttons.dart';
import 'inputs.dart';
import 'pressable.dart';

/// Height of the grabber strip at the top of an [showNSheet]: the gap above the grabber plus the
/// grabber itself. Content of a sheet with `grabberOverContent` pads its top by this much to keep
/// the usual spacing.
const double nSheetGrabberExtent = 12;

/// Solid modal bottom sheet with a grabber. Dialogs in Naali are sheets.
///
/// The grabber normally sits in a surface-coloured strip above the content. With
/// [grabberOverContent] the content starts at the sheet's top edge and the grabber floats over
/// it, so a sheet that paints its own background (a glow, a gradient) isn't cut off; pad the
/// content's top by [nSheetGrabberExtent].
Future<T?> showNSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool scrollControlled = true,
  bool grabberOverContent = false,
}) {
  final c = context.naali;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: scrollControlled,
    useRootNavigator: true,
    useSafeArea: true,
    barrierColor: c.scrim,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(NaaliRadius.sheet)),
        // Material rather than a ColoredBox, so list rows in the sheet show their ink.
        child: Material(
          color: c.surface,
          child: SafeArea(
            top: false,
            child: grabberOverContent
                ? Stack(
                    children: [
                      builder(ctx),
                      const Positioned(top: 8, left: 0, right: 0, child: Center(child: _Grabber())),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      const _Grabber(),
                      Flexible(child: builder(ctx)),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: nSheetGrabberExtent - 8,
        decoration: BoxDecoration(color: context.naali.surfaceRaised, borderRadius: BorderRadius.circular(2)),
      );
}

/// Lifts Naali cards and controls one surface step, for content inside a sheet. A sheet is
/// the card colour, so an [NCard] or [NListGroup] on it would otherwise vanish into it; under
/// this, cards take the raised colour and the controls on them (fields, chips, tracks) step up
/// once more.
class NOnSheet extends StatelessWidget {
  const NOnSheet({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.naali;
    final lifted = c.copyWith(
      surface: c.surfaceRaised,
      surfaceRaised: c.chartMuted,
      // The dark thumb sits close to chartMuted, so it steps up too; the light one is already white.
      segmentThumb: c.isDark ? Color.alphaBlend(Colors.white.withValues(alpha: 0.12), c.segmentThumb) : null,
    );
    return Theme(
      // Keeps the app's other theme extensions; the lifted palette replaces the Naali one.
      data: t.copyWith(extensions: [...t.extensions.values, lifted]),
      child: child,
    );
  }
}

/// Title (and optional note) at the top of a sheet.
class NSheetHeader extends StatelessWidget {
  const NSheetHeader(this.title, {super.key, this.subtitle, this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 8)});

  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: NaaliType.title2.copyWith(color: c.textPrimary)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: NaaliType.callout.copyWith(color: c.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Standard body for an [showNSheet]: an optional [NSheetHeader], then [child] inset 20 from the
/// sheet's sides. The child is [Flexible], so a scroll view in it scrolls instead of overflowing.
class NSheetBody extends StatelessWidget {
  const NSheetBody({super.key, this.title, this.subtitle, required this.child});

  final String? title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[NSheetHeader(title!, subtitle: subtitle), const SizedBox(height: 8)],
            Flexible(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child)),
          ],
        ),
      );
}

/// Confirmation sheet with full-width pill buttons. Resolves true on confirm.
Future<bool> showNConfirmSheet(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  bool destructive = false,
  String cancelLabel = 'Cancel',
  IconData? icon,
}) async {
  final ok = await showNSheet<bool>(
    context,
    builder: (ctx) {
      final c = ctx.naali;
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: NAvatar.icon(icon, size: 56, color: destructive ? c.danger : c.accent),
              ),
              const SizedBox(height: 16),
            ],
            Text(title, style: NaaliType.title2.copyWith(color: c.textPrimary)),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message, style: NaaliType.callout.copyWith(color: c.textSecondary)),
            ],
            const SizedBox(height: 24),
            NButton(
              label: confirmLabel,
              variant: destructive ? NButtonVariant.destructive : NButtonVariant.primary,
              expand: true,
              onPressed: () => Navigator.pop(ctx, true),
            ),
            const SizedBox(height: 8),
            NButton(
              label: cancelLabel,
              variant: NButtonVariant.secondary,
              expand: true,
              onPressed: () => Navigator.pop(ctx, false),
            ),
          ],
        ),
      );
    },
  );
  return ok ?? false;
}

/// Single text field in a sheet. Resolves to the trimmed text, or [hint] when
/// left empty and a hint is given; null on cancel.
Future<String?> showNTextSheet(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String initial = '',
  String? hint,
  String? label,
  String cancelLabel = 'Cancel',
  TextCapitalization textCapitalization = TextCapitalization.sentences,
}) {
  final controller = TextEditingController(text: initial);
  String? result() {
    final v = controller.text.trim();
    return v.isEmpty ? hint : v;
  }

  return showNSheet<String>(
    context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NSheetHeader(title, padding: EdgeInsets.zero),
          const SizedBox(height: 16),
          NTextField(
            controller: controller,
            hint: hint,
            label: label,
            autofocus: true,
            textCapitalization: textCapitalization,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => Navigator.pop(ctx, result()),
          ),
          const SizedBox(height: 20),
          NButton(label: confirmLabel, expand: true, onPressed: () => Navigator.pop(ctx, result())),
          const SizedBox(height: 8),
          NButton(
            label: cancelLabel,
            variant: NButtonVariant.secondary,
            expand: true,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    ),
  );
}

class NSheetAction<T> {
  const NSheetAction({
    required this.value,
    required this.label,
    required this.icon,
    this.subtitle,
    this.destructive = false,
    this.selected = false,
    this.leading,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData icon;
  final bool destructive;
  final bool selected;

  /// Replaces the [icon] avatar with any widget, such as an emoji avatar.
  final Widget? leading;
}

/// List of actions in a sheet. Resolves to the chosen value.
/// [message] is a quiet note under the title ("Only use these when safely stopped.").
Future<T?> showNActionSheet<T>(
  BuildContext context, {
  String? title,
  String? message,
  required List<NSheetAction<T>> actions,
}) =>
    showNSheet<T>(
      context,
      builder: (ctx) {
        final c = ctx.naali;
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) NSheetHeader(title, subtitle: message),
              for (final a in actions)
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NaaliRadius.field)),
                  leading: a.leading ?? NAvatar.icon(a.icon, color: a.destructive ? c.danger : null),
                  title: Text(a.label, style: a.destructive ? TextStyle(color: c.danger) : null),
                  subtitle: a.subtitle == null ? null : Text(a.subtitle!),
                  trailing: a.selected ? Icon(Icons.check_rounded, color: c.accent) : null,
                  onTap: () {
                    NaaliHaptics.tap();
                    Navigator.pop(ctx, a.value);
                  },
                ),
            ],
          ),
        );
      },
    );

enum NToastTone { neutral, success, danger }

/// Compact notice that drops in from the top and dismisses itself.
void showNToast(
  BuildContext context,
  String message, {
  NToastTone tone = NToastTone.neutral,
  IconData? icon,
  Duration duration = const Duration(milliseconds: 2600),
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  // Read now: the toast outlives the caller (e.g. a popped route), so its context can't be used in the builder.
  final colors = context.naali;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Toast(
      message: message,
      tone: tone,
      icon: icon,
      duration: duration,
      colors: colors,
      actionLabel: actionLabel,
      onAction: onAction,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  const _Toast({
    required this.message,
    required this.tone,
    required this.icon,
    required this.duration,
    required this.colors,
    required this.onDone,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final NToastTone tone;
  final IconData? icon;
  final Duration duration;
  final NaaliColors colors;
  final VoidCallback onDone;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final _a = AnimationController(vsync: this, duration: NaaliMotion.slow)..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _a.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final (color, icon) = switch (widget.tone) {
      NToastTone.neutral => (c.textPrimary, widget.icon ?? Icons.info_rounded),
      NToastTone.success => (c.success, widget.icon ?? Icons.check_circle_rounded),
      NToastTone.danger => (c.danger, widget.icon ?? Icons.error_rounded),
    };
    final curved = CurvedAnimation(parent: _a, curve: NaaliMotion.curve);
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, -1.4), end: Offset.zero).animate(curved),
        child: FadeTransition(
          opacity: curved,
          child: GestureDetector(
            onTap: _dismiss,
            onVerticalDragEnd: (_) => _dismiss(),
            child: Material(
              color: c.isDark ? c.surfaceRaised : c.inverse,
              borderRadius: BorderRadius.circular(NaaliRadius.field + 4),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(icon, color: widget.tone == NToastTone.neutral && !c.isDark ? c.onInverse : color, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: NaaliType.callout.copyWith(
                          color: c.isDark ? c.textPrimary : c.onInverse,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (widget.actionLabel != null) ...[
                      const SizedBox(width: 12),
                      NPressable(
                        onTap: () {
                          _dismiss();
                          widget.onAction?.call();
                        },
                        scale: 0.95,
                        semanticLabel: widget.actionLabel,
                        child: Text(
                          widget.actionLabel!,
                          style: NaaliType.callout.copyWith(
                            color: c.isDark ? c.accent : c.onInverse,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
