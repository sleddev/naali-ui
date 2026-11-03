import 'dart:async';

import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'avatar.dart';
import 'buttons.dart';

/// Solid modal bottom sheet with a grabber. Dialogs in Naali are sheets.
Future<T?> showNSheet<T>(BuildContext context, {required WidgetBuilder builder, bool scrollControlled = true}) {
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
        child: ColoredBox(
          color: c.surface,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: c.surfaceRaised, borderRadius: BorderRadius.circular(2)),
                ),
                Flexible(child: builder(ctx)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
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

class NSheetAction<T> {
  const NSheetAction({
    required this.value,
    required this.label,
    required this.icon,
    this.subtitle,
    this.destructive = false,
    this.selected = false,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData icon;
  final bool destructive;
  final bool selected;
}

/// List of actions in a sheet. Resolves to the chosen value.
Future<T?> showNActionSheet<T>(BuildContext context, {String? title, required List<NSheetAction<T>> actions}) =>
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
              if (title != null) NSheetHeader(title),
              for (final a in actions)
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NaaliRadius.field)),
                  leading: NAvatar.icon(a.icon, color: a.destructive ? c.danger : null),
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
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Toast(
      message: message,
      tone: tone,
      icon: icon,
      duration: duration,
      colors: context.naali,
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
  });

  final String message;
  final NToastTone tone;
  final IconData? icon;
  final Duration duration;
  final NaaliColors colors;
  final VoidCallback onDone;

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
