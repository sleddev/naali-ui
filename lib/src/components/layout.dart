import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// One line: [leading], then as many of [children] as fit whole, in order,
/// then [trailing]. Leading and trailing always show. A child that doesn't fit
/// is left out entirely (not painted, tapped or announced) rather than clipped
/// at the edge, so a row of pills never ends in half a pill.
class NFitRow extends MultiChildRenderObjectWidget {
  NFitRow({
    super.key,
    List<Widget> leading = const [],
    List<Widget> children = const [],
    List<Widget> trailing = const [],
    this.spacing = 8,
    this.alignment = MainAxisAlignment.center,
  })  : leadingCount = leading.length,
        trailingCount = trailing.length,
        super(children: [...leading, ...children, ...trailing]);

  final int leadingCount;
  final int trailingCount;
  final double spacing;

  /// Where the shown children sit when they leave room over. Only start,
  /// center and end apply; the rest read as start.
  final MainAxisAlignment alignment;

  @override
  RenderNFitRow createRenderObject(BuildContext context) => RenderNFitRow(
        leadingCount: leadingCount,
        trailingCount: trailingCount,
        spacing: spacing,
        alignment: alignment,
      );

  @override
  void updateRenderObject(BuildContext context, RenderNFitRow renderObject) {
    renderObject
      ..leadingCount = leadingCount
      ..trailingCount = trailingCount
      ..spacing = spacing
      ..alignment = alignment;
  }
}

class _FitParentData extends ContainerBoxParentData<RenderBox> {
  bool shown = false;
}

/// Render object behind [NFitRow].
class RenderNFitRow extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _FitParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _FitParentData> {
  RenderNFitRow({
    required this._leadingCount,
    required this._trailingCount,
    required this._spacing,
    required this._alignment,
  });

  int _leadingCount;
  set leadingCount(int value) {
    if (value == _leadingCount) return;
    _leadingCount = value;
    markNeedsLayout();
  }

  int _trailingCount;
  set trailingCount(int value) {
    if (value == _trailingCount) return;
    _trailingCount = value;
    markNeedsLayout();
  }

  double _spacing;
  set spacing(double value) {
    if (value == _spacing) return;
    _spacing = value;
    markNeedsLayout();
  }

  MainAxisAlignment _alignment;
  set alignment(MainAxisAlignment value) {
    if (value == _alignment) return;
    _alignment = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FitParentData) child.parentData = _FitParentData();
  }

  List<RenderBox> get _children {
    final list = <RenderBox>[];
    var child = firstChild;
    while (child != null) {
      list.add(child);
      child = childAfter(child);
    }
    return list;
  }

  _FitParentData _data(RenderBox child) => child.parentData! as _FitParentData;

  double _widthOf(List<RenderBox> boxes) =>
      boxes.isEmpty ? 0 : boxes.fold(0.0, (sum, b) => sum + b.size.width) + _spacing * (boxes.length - 1);

  @override
  void performLayout() {
    final all = _children;
    final start = math.min(_leadingCount, all.length);
    final split = math.max(start, all.length - _trailingCount);
    final loose = BoxConstraints(maxHeight: constraints.maxHeight);
    for (final child in all) {
      child.layout(loose, parentUsesSize: true);
    }

    final trailing = all.sublist(split);
    final shown = all.sublist(0, start);
    for (final child in all.sublist(start, split)) {
      if (_widthOf([...shown, child, ...trailing]) > constraints.maxWidth) break;
      shown.add(child);
    }
    shown.addAll(trailing);

    var changed = false;
    for (final child in all) {
      final show = shown.contains(child);
      changed |= _data(child).shown != show;
      _data(child).shown = show;
    }
    // Hidden children drop out of the semantics tree too.
    if (changed) markNeedsSemanticsUpdate();

    final content = _widthOf(shown);
    final height = shown.fold(0.0, (h, b) => math.max(h, b.size.height));
    size = constraints.constrain(Size(constraints.hasBoundedWidth ? constraints.maxWidth : content, height));

    var x = switch (_alignment) {
      MainAxisAlignment.center => (size.width - content) / 2,
      MainAxisAlignment.end => size.width - content,
      _ => 0.0,
    };
    for (final child in shown) {
      _data(child).offset = Offset(x, (height - child.size.height) / 2);
      x += child.size.width + _spacing;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final child in _children) {
      final data = _data(child);
      if (data.shown) context.paintChild(child, offset + data.offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final child in _children.reversed) {
      final data = _data(child);
      if (!data.shown) continue;
      final hit = result.addWithPaintOffset(
        offset: data.offset,
        position: position,
        hitTest: (result, transformed) => child.hitTest(result, position: transformed),
      );
      if (hit) return true;
    }
    return false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    for (final child in _children) {
      if (_data(child).shown) visitor(child);
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _children.fold(0.0, (h, c) => math.max(h, c.getMinIntrinsicHeight(double.infinity)));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _children.fold(0.0, (h, c) => math.max(h, c.getMaxIntrinsicHeight(double.infinity)));

  @override
  double computeMinIntrinsicWidth(double height) {
    final all = _children;
    final fixed = [...all.take(_leadingCount), ...all.skip(math.max(_leadingCount, all.length - _trailingCount))];
    if (fixed.isEmpty) return 0;
    return fixed.fold(0.0, (w, c) => w + c.getMinIntrinsicWidth(height)) + _spacing * (fixed.length - 1);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final all = _children;
    if (all.isEmpty) return 0;
    return all.fold(0.0, (w, c) => w + c.getMaxIntrinsicWidth(height)) + _spacing * (all.length - 1);
  }
}
