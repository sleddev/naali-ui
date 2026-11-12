import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'surfaces.dart';

class NNavItem {
  const NNavItem({required this.icon, required this.selectedIcon, required this.label});
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Floating glass tab bar with a lozenge that slides to the selected tab.
/// Put it in `Scaffold.bottomNavigationBar` with `extendBody: true`.
class NNavBar extends StatelessWidget {
  const NNavBar({super.key, required this.items, required this.index, required this.onTap});

  final List<NNavItem> items;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: NGlass(
        radius: 32,
        blur: 28,
        padding: const EdgeInsets.all(5),
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth / items.length;
            return Stack(
              children: [
                // easeOutBack overshoots; clamp each edge so the lozenge squashes against the wall.
                TweenAnimationBuilder<double>(
                  tween: Tween(end: w * index),
                  duration: const Duration(milliseconds: 320),
                  curve: NaaliMotion.spring,
                  builder: (context, x, child) {
                    final left = x < 0 ? 0.0 : x;
                    final right = (x + w).clamp(0.0, box.maxWidth);
                    return Positioned(left: left, top: 0, bottom: 0, width: right - left, child: child!);
                  },
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: const StadiumBorder(),
                      color: c.isDark ? const Color(0x29FFFFFF) : const Color(0x14000000),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: Semantics(
                          selected: i == index,
                          button: true,
                          label: items[i].label,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              NaaliHaptics.tap();
                              onTap(i);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    i == index ? items[i].selectedIcon : items[i].icon,
                                    size: 24,
                                    color: i == index ? c.textPrimary : c.textSecondary,
                                  ),
                                  const SizedBox(height: 2),
                                  AnimatedDefaultTextStyle(
                                    duration: NaaliMotion.normal,
                                    style: NaaliType.micro.copyWith(
                                      fontWeight: i == index ? FontWeight.w600 : FontWeight.w500,
                                      color: i == index ? c.textPrimary : c.textSecondary,
                                    ),
                                    child: Text(items[i].label),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Fired when the already-selected tab is tapped again; [NCollapsingPage]s
/// with that [NCollapsingPage.tabIndex] scroll back to the top.
abstract final class NTabReselect {
  static final _c = StreamController<int>.broadcast();
  static Stream<int> get stream => _c.stream;
  static void fire(int index) => _c.add(index);
}

/// Height of the header row, under the status bar.
const _kBarHeight = 60.0;

/// Tab-root page under a pinned header that floats over a progressive blur.
///
/// Two layouts:
/// * Toolbar (no [title]): one row of [leading], [middle] (usually a glass
///   [NSearchField]) and [actions], e.g. avatar · search · icon buttons.
/// * Titled: a large [title] that collapses into a small centred one as you scroll.
class NCollapsingPage extends StatefulWidget {
  const NCollapsingPage({
    super.key,
    this.title,
    required this.slivers,
    this.leading,
    this.middle,
    this.actions = const [],
    this.bottomPadding = 110,
    this.tabIndex,
    this.header,
  });

  final String? title;
  final List<Widget> slivers;
  final Widget? leading;

  /// Fills the bar between [leading] and [actions].
  final Widget? middle;
  final List<Widget> actions;

  /// Space under the content; the default clears a floating [NNavBar].
  final double bottomPadding;
  final int? tabIndex;

  /// Widget under the large title that scrolls with it (tabs, filters).
  final Widget? header;

  @override
  State<NCollapsingPage> createState() => _NCollapsingPageState();
}

class _NCollapsingPageState extends State<NCollapsingPage> {
  final _scroll = ScrollController();

  /// Header blur strength; only notifies while it changes (first few pixels).
  final _blur = ValueNotifier(0.0);
  bool _collapsed = false;
  StreamSubscription<int>? _reselect;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      _blur.value = (_scroll.offset / _kHeaderOverhang).clamp(0.0, 1.0);
      final v = _scroll.offset > 40;
      if (v != _collapsed) setState(() => _collapsed = v);
    });
    if (widget.tabIndex != null) {
      _reselect = NTabReselect.stream.where((i) => i == widget.tabIndex).listen((_) {
        if (_scroll.hasClients) _scroll.animateTo(0, duration: NaaliMotion.slow, curve: NaaliMotion.curve);
      });
    }
  }

  @override
  void dispose() {
    _reselect?.cancel();
    _scroll.dispose();
    _blur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final pad = MediaQuery.paddingOf(context);
    final title = widget.title;
    final hasRow = widget.leading != null || widget.middle != null || widget.actions.isNotEmpty;
    return ColoredBox(
      color: c.background,
      // The header floats over the scroll view rather than pinning inside it:
      // the overscroll stretch filters the scroll content, and a backdrop blur
      // inside that filter would read its offscreen texture, not the screen.
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: pad.top + _kBarHeight)),
              if (title != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(NaaliSpace.xl, 4, NaaliSpace.xl, 0),
                  sliver: SliverToBoxAdapter(
                    child: AnimatedOpacity(
                      opacity: _collapsed ? 0 : 1,
                      duration: NaaliMotion.normal,
                      child: Text(title, style: NaaliType.largeTitle.copyWith(color: c.textPrimary)),
                    ),
                  ),
                ),
              if (widget.header != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(NaaliSpace.page, 16, NaaliSpace.page, 0),
                  sliver: SliverToBoxAdapter(child: widget.header),
                ),
              ...widget.slivers,
              SliverToBoxAdapter(child: SizedBox(height: pad.bottom + widget.bottomPadding)),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Fades in over the first few pixels of scroll so whatever rests
                // just under the bar isn't blurred by the overhang.
                ValueListenableBuilder(
                  valueListenable: _blur,
                  builder: (context, k, _) => _HeaderBackdrop(strength: k),
                ),
                Padding(
                  padding: EdgeInsets.only(top: pad.top),
                  child: SizedBox(
                    height: _kBarHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (title != null)
                          AnimatedOpacity(
                            opacity: _collapsed ? 1 : 0,
                            duration: NaaliMotion.normal,
                            child: Text(title, style: NaaliType.navTitle.copyWith(color: c.textPrimary)),
                          ),
                        if (hasRow)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: NaaliSpace.page),
                            child: Row(
                              children: [
                                ?widget.leading,
                                if (widget.middle != null) ...[
                                  if (widget.leading != null) const SizedBox(width: 10),
                                  Expanded(child: widget.middle!),
                                  if (widget.actions.isNotEmpty) const SizedBox(width: 10),
                                ] else
                                  const Spacer(),
                                for (var i = 0; i < widget.actions.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 8),
                                  widget.actions[i],
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// How far a header's blur runs past its bottom edge.
const _kHeaderOverhang = 24.0;

/// Progressive blur behind a header, hanging [_kHeaderOverhang] below it so
/// content dissolves as it slides under. Must be the first child of a
/// `Stack(clipBehavior: Clip.none)` that wraps the header.
class _HeaderBackdrop extends StatelessWidget {
  const _HeaderBackdrop({required this.strength});
  final double strength;

  @override
  Widget build(BuildContext context) => Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: -_kHeaderOverhang,
        child: NProgressiveBlur(strength: strength),
      );
}

/// Top bar for pushed pages: glass back button, a bold title beside it, and
/// optional actions (usually [NGlassIconButton]s) on the right.
///
/// Transparent until content scrolls under it, then a progressive blur fades
/// in. Set `Scaffold.extendBodyBehindAppBar` so the body actually passes
/// beneath the bar.
class NTopBar extends StatefulWidget implements PreferredSizeWidget {
  const NTopBar({super.key, this.title, this.actions = const [], this.onBack, this.showBack = true});

  final String? title;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(_kBarHeight);

  /// Where a body that scrolls under an [NTopBar] (`Scaffold.extendBodyBehindAppBar`) should
  /// start its content: below the status bar and the bar.
  ///
  /// Works from a context above the Scaffold or inside its body. Inside the body the Scaffold
  /// strips the status-bar view padding, but `padding.top` then carries the full bar height.
  static double contentInset(BuildContext context) => math.max(
        MediaQuery.viewPaddingOf(context).top + _kBarHeight,
        MediaQuery.paddingOf(context).top,
      );

  @override
  State<NTopBar> createState() => _NTopBarState();
}

class _NTopBarState extends State<NTopBar> {
  ScrollNotificationObserverState? _observer;
  bool _scrolledUnder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _observer?.removeListener(_onScroll);
    _observer = ScrollNotificationObserver.maybeOf(context);
    _observer?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _observer?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll(ScrollNotification n) {
    if (n is! ScrollUpdateNotification || !defaultScrollNotificationPredicate(n)) return;
    if (n.metrics.axis != Axis.vertical) return;
    final under = n.metrics.extentBefore > 0;
    if (under != _scrolledUnder) setState(() => _scrolledUnder = under);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final canPop = widget.showBack && (widget.onBack != null || Navigator.of(context).canPop());
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(end: _scrolledUnder ? 1 : 0),
          duration: NaaliMotion.normal,
          builder: (context, k, _) => _HeaderBackdrop(strength: k),
        ),
        SafeArea(
          bottom: false,
          child: SizedBox(
            height: _kBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: NaaliSpace.page),
              child: Row(
                children: [
                  if (canPop) ...[
                    NGlassIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: widget.title == null
                        ? const SizedBox.shrink()
                        : Text(
                            widget.title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NaaliType.barTitle.copyWith(color: c.textPrimary),
                          ),
                  ),
                  for (final a in widget.actions) ...[const SizedBox(width: 8), a],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tab bodies for an [NNavBar] shell. Keeps every tab alive like an [IndexedStack] (state and
/// scroll position survive), but fades through when [index] changes: the old tab fades out, then
/// the new one fades in while settling from a slight zoom. Switches instantly when the platform
/// asks for reduced motion.
class NTabStack extends StatefulWidget {
  const NTabStack({super.key, required this.index, required this.children, this.zoom = 0.96});

  final int index;
  final List<Widget> children;

  /// Scale the incoming tab starts from.
  final double zoom;

  @override
  State<NTabStack> createState() => _NTabStackState();
}

class _NTabStackState extends State<NTabStack> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: NaaliMotion.slow, value: 1)
    ..addStatusListener((_) => setState(() {}));
  late int _previous = widget.index;

  // Fade-through: the outgoing tab is gone by 35%, the incoming one takes the rest.
  late final _fadeOutCurve = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.35, curve: Curves.easeIn));
  late final _fadeIn = CurvedAnimation(parent: _controller, curve: const Interval(0.35, 1, curve: NaaliMotion.curve));
  late final Animation<double> _fadeOut = ReverseAnimation(_fadeOutCurve);
  late final Animation<double> _zoomIn = Tween<double>(begin: widget.zoom, end: 1).animate(_fadeIn);

  @override
  void didUpdateWidget(NTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    _previous = oldWidget.index;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fadeOutCurve.dispose();
    _fadeIn.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animating = _controller.isAnimating;
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _tab(i, current: i == widget.index, leaving: animating && i == _previous),
      ],
    );
  }

  Widget _tab(int i, {required bool current, required bool leaving}) {
    // Same widget shape for every tab in every state, so switching never remounts a tab's
    // navigator; only the animations driving it change.
    return Offstage(
      key: ValueKey(i),
      offstage: !current && !leaving,
      child: TickerMode(
        enabled: current || leaving,
        child: IgnorePointer(
          ignoring: !current,
          child: FadeTransition(
            opacity: current
                ? _fadeIn
                : leaving
                    ? _fadeOut
                    : kAlwaysCompleteAnimation,
            child: ScaleTransition(
              scale: current ? _zoomIn : kAlwaysCompleteAnimation,
              child: widget.children[i],
            ),
          ),
        ),
      ),
    );
  }
}
