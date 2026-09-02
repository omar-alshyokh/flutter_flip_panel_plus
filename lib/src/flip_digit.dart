import 'dart:async';

import 'package:flutter/material.dart';

import 'flip_digit_style.dart';
import 'flip_direction.dart';
import 'flip_panel.dart';
import 'typedefs.dart';

/// The default look of a digit: centred text on a rounded, coloured box.
///
/// Exposed so callers can reuse the same styling when they supply their own
/// [DigitBuilder]. Prefer [FlipDigitStyle] for new code.
DigitBuilder defaultDigitBuilder({
  required Color digitColor,
  required Color backgroundColor,
  required double digitSize,
  required double width,
  required double height,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(0.0)),
  TextStyle? textStyle,
}) {
  final style = FlipDigitStyle(
    textColor: digitColor,
    backgroundColor: backgroundColor,
    fontSize: digitSize,
    width: width,
    height: height,
    borderRadius: borderRadius,
    textStyle: textStyle,
  );
  return style.buildDigit;
}

/// A single digit that flips whenever [value] changes.
///
/// Unlike [FlipPanelPlus] this is driven by a plain value, so it can be rebuilt
/// from any state management approach without wiring up a stream:
///
/// ```dart
/// FlipDigit(value: seconds % 10, style: const FlipDigitStyle.light())
/// ```
///
/// Appearance comes from [style]. The individual colour and size properties are
/// a shorthand used when no [style] is given; a [digitBuilder] overrides both.
class FlipDigit extends StatefulWidget {
  const FlipDigit({
    super.key,
    required this.value,
    this.style,
    this.digitBuilder,
    this.digitColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.digitSize = 32.0,
    this.width = 44.0,
    this.height = 60.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(0.0)),
    this.duration = const Duration(milliseconds: 450),
    this.direction = FlipDirection.down,
    this.spacing = 0.5,
    this.curve,
  });

  /// The digit to display. Usually 0-9.
  final int value;

  /// The look of the digit. Takes precedence over the shorthand properties.
  final FlipDigitStyle? style;

  /// Full control over rendering. Overrides [style] and the shorthand.
  final DigitBuilder? digitBuilder;

  final Color digitColor;
  final Color backgroundColor;
  final double digitSize;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  /// How long a single flip takes.
  final Duration duration;

  /// Whether the panel folds up or down.
  final FlipDirection direction;

  /// Vertical gap between the two halves, giving the split-flap seam.
  /// Set to `0` for a seamless digit with no line through the middle.
  final double spacing;

  /// Easing applied to the fold.
  final Curve? curve;

  /// The style actually used, resolving the shorthand properties.
  FlipDigitStyle get effectiveStyle =>
      style ??
      FlipDigitStyle(
        textColor: digitColor,
        backgroundColor: backgroundColor,
        fontSize: digitSize,
        width: width,
        height: height,
        borderRadius: borderRadius,
      );

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit> {
  late final StreamController<int> _controller;

  @override
  void initState() {
    super.initState();
    _controller = StreamController<int>.broadcast();
  }

  @override
  void didUpdateWidget(covariant FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Pushing the new value through the stream is what makes the panel flip.
    // Note this only happens while the element is reused; giving the widget a
    // new Key rebuilds its state from scratch and the change appears instantly.
    if (oldWidget.value != widget.value && !_controller.isClosed) {
      _controller.add(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final builder = widget.digitBuilder ?? widget.effectiveStyle.buildDigit;

    return FlipPanelPlus<int>.stream(
      itemStream: _controller.stream,
      itemBuilder: builder,
      initValue: widget.value,
      duration: widget.duration,
      direction: widget.direction,
      spacing: widget.spacing,
      curve: widget.curve,
    );
  }
}

/// A whole number rendered as a row of [FlipDigit]s.
///
/// Only the digits that actually change will flip.
///
/// ```dart
/// FlipNumber(value: score, minDigits: 4) // 0042
/// ```
class FlipNumber extends StatelessWidget {
  const FlipNumber({
    super.key,
    required this.value,
    this.minDigits = 1,
    this.style,
    this.digitBuilder,
    this.digitColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.digitSize = 32.0,
    this.width = 44.0,
    this.height = 60.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(0.0)),
    this.duration = const Duration(milliseconds: 450),
    this.direction = FlipDirection.down,
    this.spacing = 0.5,
    this.digitSpacing = const EdgeInsets.symmetric(horizontal: 2.0),
    this.curve,
  }) : assert(minDigits > 0, 'minDigits must be at least 1');

  /// The number to display. Negative values are shown by their absolute value.
  final int value;

  /// Pads with leading zeros up to this many digits.
  final int minDigits;

  /// The look of each digit.
  final FlipDigitStyle? style;

  final DigitBuilder? digitBuilder;
  final Color digitColor;
  final Color backgroundColor;
  final double digitSize;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Duration duration;
  final FlipDirection direction;
  final double spacing;
  final Curve? curve;

  /// Gap around each digit.
  final EdgeInsets digitSpacing;

  @override
  Widget build(BuildContext context) {
    final text = value.abs().toString().padLeft(minDigits, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      // A number reads left to right in every script, Eastern Arabic numerals
      // included, so the digits must not follow an ambient RTL Directionality.
      textDirection: TextDirection.ltr,
      children: [
        for (int i = 0; i < text.length; i++)
          Padding(
            padding: digitSpacing,
            child: FlipDigit(
              // Keyed by position so digits keep their state as the number grows.
              key: ValueKey<int>(text.length - i),
              value: int.parse(text[i]),
              style: style,
              digitBuilder: digitBuilder,
              digitColor: digitColor,
              backgroundColor: backgroundColor,
              digitSize: digitSize,
              width: width,
              height: height,
              borderRadius: borderRadius,
              duration: duration,
              direction: direction,
              spacing: spacing,
              curve: curve,
            ),
          ),
      ],
    );
  }
}
