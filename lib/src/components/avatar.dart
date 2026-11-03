import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/typography.dart';

/// Round avatar for list rows and headers: initials, an icon, or an image.
/// An optional [badge] (flag, status icon, card brand) sits on the bottom-right edge.
class NAvatar extends StatelessWidget {
  const NAvatar.initials(String name, {super.key, this.size = 40, this.color, this.badge})
      : _name = name,
        icon = null,
        image = null;

  const NAvatar.icon(IconData this.icon, {super.key, this.size = 40, this.color, this.badge})
      : _name = null,
        image = null;

  const NAvatar.image(ImageProvider this.image, {super.key, this.size = 40, this.badge})
      : _name = null,
        icon = null,
        color = null;

  final String? _name;
  final IconData? icon;
  final ImageProvider? image;
  final double size;

  /// Tint for initials/icon avatars. Initials pick one from the name when null;
  /// icon avatars stay neutral grey.
  final Color? color;
  final Widget? badge;

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    Widget circle;
    if (image != null) {
      circle = ClipOval(child: Image(image: image!, width: size, height: size, fit: BoxFit.cover));
    } else {
      final tint = color ??
          (_name != null ? c.categorical[_name.codeUnits.fold<int>(0, (a, b) => a + b) % c.categorical.length] : null);
      circle = Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: tint == null ? c.surfaceRaised : tint.withValues(alpha: c.isDark ? 0.18 : 0.14),
        ),
        child: icon != null
            ? Icon(icon, size: size * 0.5, color: tint ?? c.textPrimary)
            : Text(
                initialsOf(_name!),
                style: NaaliType.number(size * 0.38, color: tint ?? c.textPrimary).copyWith(letterSpacing: 0),
              ),
      );
    }
    if (badge == null) return SizedBox.square(dimension: size, child: circle);
    final b = size * 0.42;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: b + 4,
              height: b + 4,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.surface),
              child: ClipOval(child: SizedBox.square(dimension: b, child: badge)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Coloured circle used as an avatar badge (e.g. a status dot or brand mark).
class NBadgeDot extends StatelessWidget {
  const NBadgeDot({super.key, required this.color, this.icon});
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: icon == null ? null : Icon(icon, size: box.maxWidth * 0.7, color: Colors.white),
        ),
      );
}

/// Overlapping row of avatars ("Shared with 4 people").
class NAvatarStack extends StatelessWidget {
  const NAvatarStack({super.key, required this.names, this.size = 32, this.max = 4});
  final List<String> names;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final shown = names.take(max).toList();
    final extra = names.length - shown.length;
    final items = <Widget>[
      for (final n in shown) NAvatar.initials(n, size: size),
      if (extra > 0)
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.surfaceRaised, shape: BoxShape.circle),
          child: Text('+$extra', style: NaaliType.micro.copyWith(color: c.textPrimary)),
        ),
    ];
    final step = size * 0.68;
    return SizedBox(
      height: size + 4,
      width: step * (items.length - 1) + size + 4,
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            Positioned(
              left: i * step,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: c.surface, shape: BoxShape.circle),
                child: items[i],
              ),
            ),
        ],
      ),
    );
  }
}
