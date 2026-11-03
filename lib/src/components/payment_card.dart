import 'package:flutter/material.dart';

import '../foundation/typography.dart';
import 'pressable.dart';

/// Finishes for [NPaymentCard]. Bold gradients, like a physical card.
enum NCardFinish {
  ocean([Color(0xFF0A6CFF), Color(0xFF5B2EFF)]),
  midnight([Color(0xFF2A2C33), Color(0xFF0B0B0E)]),
  sunset([Color(0xFFFF6A3D), Color(0xFFE5267A)]),
  mint([Color(0xFF1DC497), Color(0xFF0B7C8C)]),
  metal([Color(0xFFD7DADF), Color(0xFF8A9099)]);

  const NCardFinish(this.colors);
  final List<Color> colors;

  bool get lightInk => this != NCardFinish.metal;
}

/// Payment card visual at the ISO ID-1 aspect ratio, with label, masked number and network.
class NPaymentCard extends StatelessWidget {
  const NPaymentCard({
    super.key,
    this.finish = NCardFinish.ocean,
    this.label = 'Virtual',
    this.last4 = '4242',
    this.network = 'VISA',
    this.holder,
    this.frozen = false,
    this.onTap,
    this.width,
  });

  final NCardFinish finish;
  final String label;
  final String last4;
  final String network;
  final String? holder;

  /// Frozen cards are desaturated with a snowflake.
  final bool frozen;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final ink = finish.lightInk ? Colors.white : const Color(0xFF191C1F);
    final soft = ink.withValues(alpha: 0.72);
    Widget card = AspectRatio(
      aspectRatio: 1.586,
      child: LayoutBuilder(
        builder: (context, box) {
          final s = box.maxWidth / 320;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18 * s),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: finish.colors),
            ),
            child: Stack(
              children: [
                // Soft sheen across the top-right corner.
                Positioned(
                  right: -60 * s,
                  top: -80 * s,
                  child: Container(
                    width: 220 * s,
                    height: 220 * s,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(18 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(label, style: NaaliType.headline.copyWith(color: ink, fontSize: 15 * s)),
                          const Spacer(),
                          Icon(Icons.contactless_outlined, color: soft, size: 22 * s),
                        ],
                      ),
                      SizedBox(height: 14 * s),
                      _Chip(scale: s),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (holder != null)
                                  Text(holder!, style: NaaliType.caption.copyWith(color: soft, fontSize: 12 * s)),
                                Text('•• $last4',
                                    style: NaaliType.number(18 * s, color: ink).copyWith(letterSpacing: 1.5 * s)),
                              ],
                            ),
                          ),
                          Text(
                            network,
                            style: TextStyle(
                              fontFamily: NaaliType.display,
                              fontSize: 22 * s,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              letterSpacing: -0.5,
                              color: ink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (frozen)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18 * s),
                        color: const Color(0xFFB9D7F5).withValues(alpha: 0.55),
                      ),
                      child: Icon(Icons.ac_unit_rounded, color: Colors.white, size: 44 * s),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
    if (width != null) card = SizedBox(width: width, child: card);
    return onTap == null ? card : NPressable(onTap: onTap, scale: 0.97, child: card);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) => Container(
        width: 38 * scale,
        height: 28 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6 * scale),
          gradient: const LinearGradient(colors: [Color(0xFFF3D98B), Color(0xFFC9A64B)]),
        ),
        child: CustomPaint(painter: _ChipLines()),
      );
}

class _ChipLines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x55000000)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), p);
    canvas.drawLine(Offset(size.width * 0.65, 0), Offset(size.width * 0.65, size.height), p);
  }

  @override
  bool shouldRepaint(_ChipLines oldDelegate) => false;
}
