import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/colors.dart';
import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'pressable.dart';

/// Filled, rounded text field with a floating label, helper/error line and
/// optional prefix icon. Focus draws an accent outline.
class NTextField extends StatelessWidget {
  const NTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.prefixIcon,
    this.suffix,
    this.suffixText,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final IconData? prefixIcon;
  final Widget? suffix;

  /// Unit shown at the end of the value ("hp", "kg").
  final String? suffixText;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool enabled;
  final int maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      inputFormatters: inputFormatters,
      style: NaaliType.bodyLarge.copyWith(color: c.textPrimary, height: 1.25),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: error == null ? helper : null,
        errorText: error,
        helperStyle: NaaliType.footnote.copyWith(color: c.textSecondary),
        errorStyle: NaaliType.footnote.copyWith(color: c.danger),
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: c.textSecondary, size: 22),
        suffixIcon: suffix,
        suffixText: suffixText,
        suffixStyle: NaaliType.bodyLarge.copyWith(color: c.textSecondary, height: 1.25),
      ),
    );
  }
}

/// Pill search field on a raised fill, as in list headers.
class NSearchField extends StatefulWidget {
  const NSearchField({
    super.key,
    this.hint = 'Search',
    this.onChanged,
    this.controller,
    this.onTap,
    this.readOnly = false,
    this.glass = false,
  });

  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  /// With [readOnly], the field acts as a button that opens a search page.
  final VoidCallback? onTap;
  final bool readOnly;

  /// Translucent pill with a hairline rim, matching [NGlassIconButton], for
  /// use in a header bar.
  final bool glass;

  @override
  State<NSearchField> createState() => _NSearchFieldState();
}

class _NSearchFieldState extends State<NSearchField> {
  late final _c = widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    _c.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _c.removeListener(_rebuild);
    if (widget.controller == null) _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final pill = OutlineInputBorder(
      borderRadius: BorderRadius.circular(NaaliRadius.pill),
      borderSide: widget.glass ? BorderSide(color: c.glassBorder, width: 0.6) : BorderSide.none,
    );
    return SizedBox(
      height: widget.glass ? 46 : 42,
      child: TextField(
        controller: _c,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        style: NaaliType.bodyText.copyWith(color: c.textPrimary, height: 1.2),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: NaaliType.bodyText.copyWith(color: c.textSecondary, height: 1.2),
          contentPadding: EdgeInsets.zero,
          prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary, size: 22),
          suffixIcon: _c.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.cancel_rounded, size: 18, color: c.textSecondary),
                  onPressed: () {
                    _c.clear();
                    widget.onChanged?.call('');
                  },
                ),
          filled: true,
          fillColor: widget.glass ? c.glassFillStrong : c.surfaceRaised,
          border: pill,
          enabledBorder: pill,
          focusedBorder: pill,
        ),
      ),
    );
  }
}

/// Big centred amount being typed ("€120.5"), with a caption under it.
/// Pair with [NNumberPad] and [NAmountController].
class NAmountDisplay extends StatelessWidget {
  const NAmountDisplay({super.key, required this.text, this.symbol = '€', this.caption, this.error = false});

  final String text;
  final String symbol;
  final String? caption;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    final empty = text.isEmpty;
    final color = error ? c.danger : (empty ? c.textTertiary : c.textPrimary);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedDefaultTextStyle(
            duration: NaaliMotion.fast,
            style: NaaliType.number(56, color: color),
            child: Text('$symbol${empty ? '0' : text}'),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 8),
          Text(caption!, style: NaaliType.callout.copyWith(color: error ? c.danger : c.textSecondary)),
        ],
      ],
    );
  }
}

/// Text buffer for [NNumberPad] that enforces one decimal point and [decimals] places.
class NAmountController extends ValueNotifier<String> {
  NAmountController({this.decimals = 2, this.maxWhole = 9}) : super('');
  final int decimals;
  final int maxWhole;

  double get amount => double.tryParse(value) ?? 0;

  void input(String key) {
    final v = value;
    if (key == '.') {
      if (decimals == 0 || v.contains('.')) return;
      value = v.isEmpty ? '0.' : '$v.';
      return;
    }
    final dot = v.indexOf('.');
    if (dot >= 0 && v.length - dot > decimals) return;
    if (dot < 0 && v.replaceAll('0', '').isEmpty && key == '0' && v.isNotEmpty) return;
    if (dot < 0 && v.length >= maxWhole) return;
    value = (v == '0') ? key : '$v$key';
  }

  void backspace() {
    if (value.isNotEmpty) value = value.substring(0, value.length - 1);
  }

  void clear() => value = '';
}

/// Phone-style keypad for entering amounts and PINs.
class NNumberPad extends StatelessWidget {
  const NNumberPad({super.key, required this.onKey, required this.onBackspace, this.showDecimal = true, this.keyHeight = 60});

  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  final bool showDecimal;
  final double keyHeight;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    Widget key(Widget child, VoidCallback? onTap) => Expanded(
          child: NPressable(
            onTap: onTap,
            scale: 0.88,
            child: SizedBox(height: keyHeight, child: Center(child: child)),
          ),
        );
    Widget digit(String d) => key(Text(d, style: NaaliType.number(28, weight: FontWeight.w500, color: c.textPrimary)), () => onKey(d));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(children: [for (final d in row) digit(d)]),
        Row(
          children: [
            showDecimal ? digit('.') : const Expanded(child: SizedBox()),
            digit('0'),
            key(Icon(Icons.backspace_outlined, color: c.textPrimary, size: 24), onBackspace),
          ],
        ),
      ],
    );
  }
}

/// Row of boxes for one-time codes / PINs. Filled boxes show a dot.
class NPinDots extends StatelessWidget {
  const NPinDots({super.key, required this.length, required this.filled, this.error = false});
  final int length;
  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < length; i++)
          AnimatedContainer(
            duration: NaaliMotion.fast,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: error ? c.danger : (i < filled ? c.textPrimary : c.surfaceRaised),
            ),
          ),
      ],
    );
  }
}
