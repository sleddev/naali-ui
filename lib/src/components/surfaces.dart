import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import 'pressable.dart';

/// Solid rounded card on the canvas. No borders, gradients or shadows:
/// hierarchy comes from spacing and type.
class NCard extends StatelessWidget {
  const NCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = NaaliRadius.card,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    Widget card = Material(
      color: color ?? context.naali.surface,
      borderRadius: br,
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
    if (onTap != null) card = NPressable(onTap: onTap, scale: 0.98, child: card);
    return margin == null ? card : Padding(padding: margin!, child: card);
  }
}

/// Frosted surface for controls floating over content (nav bar, map buttons, HUDs).
/// Content pages use [NCard] instead.
class NGlass extends StatelessWidget {
  const NGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.blur = 24,
    this.strong = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final bool strong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final br = BorderRadius.circular(radius);
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: br,
        color: strong ? c.glassFillStrong : c.glassFill,
        border: Border.all(color: c.glassBorder, width: 0.6),
      ),
      child: Padding(padding: padding, child: child),
    );
    final filter = ImageFilter.blur(sigmaX: blur, sigmaY: blur);
    Widget out = ClipRRect(
      borderRadius: br,
      child: blur <= 0
          ? decorated
          : BackdropGroup.of(context) != null
              ? BackdropFilter.grouped(filter: filter, child: decorated)
              : BackdropFilter(filter: filter, child: decorated),
    );
    if (onTap != null) out = NPressable(onTap: onTap, scale: 0.95, child: out);
    return out;
  }
}

/// Backdrop blur that is strongest at the top edge and dissolves to nothing at
/// the bottom, under a matching tint, so content scrolling beneath a header
/// melts away instead of meeting a hard edge. Fills its parent.
///
/// On Impeller the blur radius ramps continuously, via a fragment shader. Where
/// shader filters aren't supported (Skia, web) it falls back to [steps]
/// stacked strips of decreasing blur, which show faint seams.
class NProgressiveBlur extends StatefulWidget {
  const NProgressiveBlur({
    super.key,
    this.sigma = 16,
    this.steps = 8,
    this.tint,
    this.tintOpacity = 0.85,
    this.strength = 1,
  });

  /// Blur at the top edge.
  final double sigma;

  /// Strips in the fallback.
  final int steps;

  /// Defaults to the canvas colour.
  final Color? tint;

  /// Tint alpha at the top edge; it fades out with the blur.
  final double tintOpacity;

  /// 0–1; scales blur and tint together, for fading the effect in.
  final double strength;

  @override
  State<NProgressiveBlur> createState() => _NProgressiveBlurState();
}

class _NProgressiveBlurState extends State<NProgressiveBlur> {
  static Future<FragmentProgram>? _loading;
  static FragmentProgram? _program;

  FragmentShader? _h;
  FragmentShader? _v;

  @override
  void initState() {
    super.initState();
    if (_program != null) {
      _initShaders();
    } else if (ImageFilter.isShaderFilterSupported) {
      _loading ??= FragmentProgram.fromAsset('packages/naali_ui/shaders/progressive_blur.frag');
      _loading!.then((p) {
        _program = p;
        if (mounted) setState(_initShaders);
      }, onError: (Object _) {});
    }
  }

  void _initShaders() {
    _h = _program!.fragmentShader();
    _v = _program!.fragmentShader();
  }

  @override
  void dispose() {
    _h?.dispose();
    _v?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tint ?? context.naali.background;
    final k = widget.strength.clamp(0.0, 1.0);
    final Widget blur;
    if (_h != null) {
      // Stays mounted at strength 0 (a cheap pass-through) so the pipeline is
      // built while idle, not on the first scroll frame that shows the blur.
      blur = ClipRect(
        child: _ShaderBlur(
          horizontal: _h!,
          vertical: _v!,
          sigma: widget.sigma * k,
          devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
        ),
      );
    } else if (k == 0) {
      blur = const SizedBox.expand();
    } else {
      final n = widget.steps;
      blur = Opacity(
        opacity: k,
        child: Column(
          children: [
            for (var i = 0; i < n; i++)
              Expanded(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.sigma * (n - i - 0.5) / n,
                      sigmaY: widget.sigma * (n - i - 0.5) / n,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    final a = widget.tintOpacity * k;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          blur,
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [t.withValues(alpha: a), t.withValues(alpha: a * 0.55), t.withValues(alpha: 0)],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Backdrop filter running the two passes of `progressive_blur.frag`.
class _ShaderBlur extends LeafRenderObjectWidget {
  const _ShaderBlur({
    required this.horizontal,
    required this.vertical,
    required this.sigma,
    required this.devicePixelRatio,
  });

  final FragmentShader horizontal;
  final FragmentShader vertical;
  final double sigma;
  final double devicePixelRatio;

  @override
  _RenderShaderBlur createRenderObject(BuildContext context) =>
      _RenderShaderBlur(horizontal, vertical, sigma, devicePixelRatio);

  @override
  void updateRenderObject(BuildContext context, _RenderShaderBlur r) => r
    ..horizontal = horizontal
    ..vertical = vertical
    ..sigma = sigma
    ..devicePixelRatio = devicePixelRatio;
}

class _RenderShaderBlur extends RenderBox {
  _RenderShaderBlur(this._horizontal, this._vertical, this._sigma, this._devicePixelRatio);

  FragmentShader _horizontal;
  set horizontal(FragmentShader v) {
    if (v == _horizontal) return;
    _horizontal = v;
    markNeedsPaint();
  }

  FragmentShader _vertical;
  set vertical(FragmentShader v) {
    if (v == _vertical) return;
    _vertical = v;
    markNeedsPaint();
  }

  double _sigma;
  set sigma(double v) {
    if (v == _sigma) return;
    _sigma = v;
    markNeedsPaint();
  }

  double _devicePixelRatio;
  set devicePixelRatio(double v) {
    if (v == _devicePixelRatio) return;
    _devicePixelRatio = v;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    // The shader sees backdrop-texture pixels, so place the ramp in those.
    final top = localToGlobal(Offset.zero).dy * _devicePixelRatio;
    for (final (shader, dir) in [(_horizontal, 0.0), (_vertical, 1.0)]) {
      shader
        ..setFloat(2, top)
        ..setFloat(3, size.height * _devicePixelRatio)
        ..setFloat(4, _sigma * _devicePixelRatio)
        ..setFloat(5, dir);
    }
    // A fresh layer every paint: shader filters compare equal by shader
    // identity, so a reused layer would never resend the new uniforms.
    layer = BackdropFilterLayer(
      filter: ImageFilter.compose(outer: ImageFilter.shader(_vertical), inner: ImageFilter.shader(_horizontal)),
    );
    context.pushLayer(layer! as BackdropFilterLayer, (context, offset) {}, offset);
  }
}

/// Circular glass icon button for headers and for use over imagery or maps.
class NGlassIconButton extends StatelessWidget {
  const NGlassIconButton({super.key, required this.icon, required this.onPressed, this.size = 46, this.tooltip});

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = SizedBox.square(
      dimension: size,
      child: NGlass(
        radius: size / 2,
        padding: EdgeInsets.zero,
        strong: true,
        onTap: onPressed,
        child: Center(child: Icon(icon, size: size * 0.48, color: context.naali.textPrimary)),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}
