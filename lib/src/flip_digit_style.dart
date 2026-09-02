import 'package:flutter/material.dart';

/// The look of a single flipping digit.
///
/// Bundling the visuals into one object means a look can be defined once and
/// reused, instead of repeating a dozen arguments at every call site:
///
/// ```dart
/// const style = FlipDigitStyle.card(seed: Colors.indigo);
///
/// FlipCountdown(duration: d, style: style);
/// FlipNumber(value: n, style: style);
/// ```
///
/// Start from one of the presets ([FlipDigitStyle.dark],
/// [FlipDigitStyle.light], [FlipDigitStyle.minimal], [FlipDigitStyle.card])
/// and adjust with [copyWith].
@immutable
class FlipDigitStyle {
  const FlipDigitStyle({
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.gradient,
    this.textStyle,
    this.fontSize = 32.0,
    this.width = 44.0,
    this.height = 60.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.border,
    this.boxShadow,
    this.padding,
    this.digitFormatter,
  });

  /// Colour of the digit itself. Ignored where [textStyle] sets a colour.
  final Color textColor;

  /// Solid fill behind the digit. Ignored when [gradient] is set.
  final Color backgroundColor;

  /// Fill behind the digit. Takes precedence over [backgroundColor].
  final Gradient? gradient;

  /// Full control over the digit's text. Any field left null falls back to
  /// [fontSize] / [textColor] and a bold weight.
  final TextStyle? textStyle;

  final double fontSize;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  /// Inset around the digit inside its box.
  final EdgeInsetsGeometry? padding;

  /// Converts a digit to the text shown for it.
  ///
  /// Use it to render another numeral system, for example
  /// [FlipDigitStyle.easternArabicNumerals]. Defaults to Western digits.
  final String Function(int digit)? digitFormatter;

  /// Renders digits as Eastern Arabic numerals (٠١٢٣٤٥٦٧٨٩).
  ///
  /// ```dart
  /// style: const FlipDigitStyle.dark()
  ///     .copyWith(digitFormatter: FlipDigitStyle.easternArabicNumerals)
  /// ```
  static String easternArabicNumerals(int digit) {
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    return digit.toString().split('').map((c) {
      final i = int.tryParse(c);
      return i == null ? c : eastern[i];
    }).join();
  }

  /// The classic split-flap board: white on black.
  const FlipDigitStyle.dark({
    double fontSize = 32.0,
    double width = 44.0,
    double height = 60.0,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(4.0)),
  }) : this(
          textColor: Colors.white,
          backgroundColor: Colors.black,
          fontSize: fontSize,
          width: width,
          height: height,
          borderRadius: borderRadius,
        );

  /// Inverted: dark digits on a light card with a hairline border.
  const FlipDigitStyle.light({
    double fontSize = 32.0,
    double width = 44.0,
    double height = 60.0,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(6.0)),
  }) : this(
          textColor: const Color(0xFF1B1B1B),
          backgroundColor: Colors.white,
          fontSize: fontSize,
          width: width,
          height: height,
          borderRadius: borderRadius,
          border: const Border.fromBorderSide(
            BorderSide(color: Color(0xFFDDDDDD)),
          ),
        );

  /// No box at all, just the digits, for overlaying on artwork or a photo.
  const FlipDigitStyle.minimal({
    Color color = Colors.white,
    double fontSize = 34.0,
    double width = 34.0,
    double height = 46.0,
  }) : this(
          textColor: color,
          backgroundColor: Colors.transparent,
          fontSize: fontSize,
          width: width,
          height: height,
          borderRadius: BorderRadius.zero,
        );

  /// A raised card, tinted from [seed].
  FlipDigitStyle.card({
    Color seed = const Color(0xFF2A2A2A),
    double fontSize = 30.0,
    double width = 46.0,
    double height = 62.0,
  }) : this(
          textColor: Colors.white,
          backgroundColor: seed,
          fontSize: fontSize,
          width: width,
          height: height,
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          boxShadow: [
            BoxShadow(
              color: seed.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );

  /// The resolved text style for a digit.
  ///
  /// A line height of 1.0 with evenly distributed leading is important here:
  /// by default a text line box carries the font's ascent and descent, and
  /// digits use no descender, so centring the *line box* inside the panel
  /// leaves visibly more space on one side of the glyph than the other.
  TextStyle resolveTextStyle() {
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: textColor,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
    );
    return textStyle == null ? base : base.merge(textStyle);
  }

  /// The resolved box decoration behind a digit.
  BoxDecoration resolveDecoration() => BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
      );

  /// Renders one digit in this style.
  Widget buildDigit(BuildContext context, int digit) {
    final child = Container(
      alignment: Alignment.center,
      width: width,
      height: height,
      padding: padding,
      decoration: resolveDecoration(),
      child: Text(
        digitFormatter?.call(digit) ?? '$digit',
        style: resolveTextStyle(),
      ),
    );
    return child;
  }

  FlipDigitStyle copyWith({
    Color? textColor,
    Color? backgroundColor,
    Gradient? gradient,
    TextStyle? textStyle,
    double? fontSize,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    EdgeInsetsGeometry? padding,
    String Function(int digit)? digitFormatter,
  }) {
    return FlipDigitStyle(
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradient: gradient ?? this.gradient,
      textStyle: textStyle ?? this.textStyle,
      fontSize: fontSize ?? this.fontSize,
      width: width ?? this.width,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      boxShadow: boxShadow ?? this.boxShadow,
      padding: padding ?? this.padding,
      digitFormatter: digitFormatter ?? this.digitFormatter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlipDigitStyle &&
          other.textColor == textColor &&
          other.backgroundColor == backgroundColor &&
          other.gradient == gradient &&
          other.textStyle == textStyle &&
          other.fontSize == fontSize &&
          other.width == width &&
          other.height == height &&
          other.borderRadius == borderRadius &&
          other.border == border &&
          other.padding == padding &&
          other.digitFormatter == digitFormatter;

  @override
  int get hashCode => Object.hash(textColor, backgroundColor, gradient,
      textStyle, fontSize, width, height, borderRadius, border, padding,
      digitFormatter);
}

/// Where the caption sits relative to its digits in a countdown.
enum FlipLabelPosition {
  /// Above the digits.
  above,

  /// Below the digits. This is the default.
  below,
}
