import 'dart:async';

import 'package:flutter/material.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'buttons.dart';
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
                                  Icon(i == index ? items[i].selectedIcon : items[i].icon,
                                      size: 24, color: i == index ? c.textPrimary : c.textSecondary),
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

/// Tab-root page: a large title that collapses into a small centred title on a
/// solid bar as you scroll. Optional leading widget and trailing actions.
class NCollapsingPage extends StatefulWidget {
  const NCollapsingPage({
    super.key,
    required this.title,
    required this.slivers,
    this.leading,
    this.actions = const [],
    this.bottomPadding = 110,
    this.tabIndex,
    this.header,
  });

  final String title;
  final List<Widget> slivers;
  final Widget? leading;
  final List<Widget> actions;

  /// Space under the content; the default clears a floating [NNavBar].
  final double bottomPadding;
  final int? tabIndex;

  /// Widget under the large title that scrolls with it (search field, tabs).
  final Widget? header;

  @override
  State<NCollapsingPage> createState() => _NCollapsingPageState();
}

class _NCollapsingPageState extends State<NCollapsingPage> {
  final _scroll = ScrollController();
  bool _collapsed = false;
  StreamSubscription<int>? _reselect;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final pad = MediaQuery.paddingOf(context);
    final hasBar = widget.leading != null || widget.actions.isNotEmpty;
    return ColoredBox(
      color: c.background,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          PinnedHeaderSliver(
            child: AnimatedContainer(
              duration: NaaliMotion.normal,
              padding: EdgeInsets.only(top: pad.top),
              decoration: BoxDecoration(
                color: c.background,
                border: Border(bottom: BorderSide(color: _collapsed ? c.hairline : Colors.transparent)),
              ),
              child: SizedBox(
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedOpacity(
                      opacity: _collapsed ? 1 : 0,
                      duration: NaaliMotion.normal,
                      child: Text(widget.title, style: NaaliType.navTitle.copyWith(color: c.textPrimary)),
                    ),
                    if (hasBar)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: NaaliSpace.page),
                        child: Row(
                          children: [
                            ?widget.leading,
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
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(NaaliSpace.xl, 4, NaaliSpace.xl, 0),
            sliver: SliverToBoxAdapter(
              child: AnimatedOpacity(
                opacity: _collapsed ? 0 : 1,
                duration: NaaliMotion.normal,
                child: Text(widget.title, style: NaaliType.largeTitle.copyWith(color: c.textPrimary)),
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
    );
  }
}

/// Top bar for pushed pages: circular back button, centred title, optional actions.
class NTopBar extends StatelessWidget implements PreferredSizeWidget {
  const NTopBar({super.key, this.title, this.actions = const [], this.onBack, this.showBack = true});

  final String? title;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final canPop = showBack && (onBack != null || Navigator.of(context).canPop());
    return ColoredBox(
      color: c.background,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NaaliSpace.page),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 56),
                    child: Text(title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NaaliType.navTitle.copyWith(color: c.textPrimary)),
                  ),
                Row(
                  children: [
                    if (canPop)
                      NIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                      ),
                    const Spacer(),
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      actions[i],
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
