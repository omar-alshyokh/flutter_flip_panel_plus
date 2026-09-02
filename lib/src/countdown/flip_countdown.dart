import 'package:flutter/material.dart';

import '../flip_digit.dart';
import '../flip_digit_style.dart';
import '../flip_direction.dart';
import '../typedefs.dart';
import 'flip_countdown_builder.dart';
import 'flip_countdown_controller.dart';

/// Text shown beside each segment of a [FlipCountdown] when
/// [FlipCountdown.showLabels] is enabled.
@immutable
class FlipCountdownLabels {
  const FlipCountdownLabels({
    this.days = 'DAYS',
    this.hours = 'HOURS',
    this.minutes = 'MINUTES',
    this.seconds = 'SECONDS',
  });

  /// Short forms, handy for compact layouts.
  const FlipCountdownLabels.short()
      : days = 'D',
        hours = 'H',
        minutes = 'M',
        seconds = 'S';

  final String days;
  final String hours;
  final String minutes;
  final String seconds;
}

/// A countdown rendered with flipping digits.
///
/// Give it a [duration] or a [targetDate], or pass your own [controller] when
/// you need to pause, resume or reset it from elsewhere.
///
/// ```dart
/// FlipCountdown(
///   targetDate: saleEndsAt,
///   referenceTime: serverNow, // don't trust the device clock
///   style: FlipDigitStyle.card(seed: Colors.indigo),
///   completedBuilder: (context) => const Text('EXPIRED'),
/// )
/// ```
///
/// Segments are chosen automatically: days appear only when the countdown is a
/// day or more, hours only when it is an hour or more. Override with
/// [showDays] / [showHours], and hide the smaller units with [showMinutes] /
/// [showSeconds].
///
/// For a countdown that looks nothing like this, use [FlipCountdownBuilder] and
/// render whatever you like from the same timing engine.
class FlipCountdown extends StatelessWidget {
  const FlipCountdown({
    super.key,
    this.controller,
    this.duration,
    this.targetDate,
    this.referenceTime,
    this.autoStart = true,
    this.onDone,
    this.onTick,
    this.completedBuilder,
    this.showDays,
    this.showHours,
    this.showMinutes = true,
    this.showSeconds = true,
    this.showLabels = false,
    this.labels = const FlipCountdownLabels(),
    this.labelStyle,
    this.labelPosition = FlipLabelPosition.below,
    this.labelSpacing = 4.0,
    this.style,
    this.digitBuilder,
    this.digitColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.digitSize = 32.0,
    this.width = 44.0,
    this.height = 60.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(3.0)),
    this.separator,
    this.spacing = const EdgeInsets.symmetric(horizontal: 2.0),
    this.flipDuration = const Duration(milliseconds: 450),
    this.direction = FlipDirection.down,
    this.panelSpacing = 0.5,
    this.curve,
    this.textDirection = TextDirection.ltr,
  }) : assert(
          controller != null || duration != null || targetDate != null,
          'Provide a controller, a duration, or a targetDate.',
        );

  /// An externally owned controller. When supplied, [duration], [targetDate],
  /// [referenceTime] and [autoStart] are ignored, and the controller is **not**
  /// disposed by this widget.
  final FlipCountdownController? controller;

  /// Counts down this long. Ignored when [controller] is given.
  final Duration? duration;

  /// Counts down until this moment. Ignored when [controller] is given.
  final DateTime? targetDate;

  /// The "now" that [targetDate] is measured against. Pass your server time to
  /// avoid trusting the device clock.
  final DateTime? referenceTime;

  /// Whether to start counting immediately.
  final bool autoStart;

  /// Called once when the countdown reaches zero.
  final VoidCallback? onDone;

  /// Called on every tick with the time remaining.
  final ValueChanged<Duration>? onTick;

  /// Replaces the digits once the countdown finishes, with an "EXPIRED"
  /// message, a sold-out badge, anything. When null the digits stay at zero.
  final WidgetBuilder? completedBuilder;

  /// Force the days segment on or off. Null picks automatically.
  final bool? showDays;

  /// Force the hours segment on or off. Null picks automatically.
  final bool? showHours;

  final bool showMinutes;
  final bool showSeconds;

  /// Whether to show a caption beside each segment.
  final bool showLabels;
  final FlipCountdownLabels labels;
  final TextStyle? labelStyle;

  /// Whether captions sit above or below the digits.
  final FlipLabelPosition labelPosition;

  /// Gap between the digits and their caption.
  final double labelSpacing;

  /// The look of each digit. Takes precedence over the shorthand properties.
  final FlipDigitStyle? style;

  /// Full control over digit rendering. Overrides [style] and the shorthand.
  final DigitBuilder? digitBuilder;

  final Color digitColor;
  final Color backgroundColor;
  final double digitSize;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  /// Widget placed between segments. Defaults to a colon matching the digits.
  /// Pass a [SizedBox.shrink] to remove it.
  final Widget? separator;

  /// Gap around each digit and separator.
  final EdgeInsets spacing;

  /// How long a single flip takes.
  final Duration flipDuration;

  final FlipDirection direction;

  /// Vertical gap between the two halves of a digit, giving the split-flap seam.
  /// Set to `0` for a seamless digit with no line through the middle.
  final double panelSpacing;

  /// Easing applied to the fold.
  final Curve? curve;

  /// The order the segments are laid out in.
  ///
  /// Defaults to [TextDirection.ltr]. A clock reads left to right in every
  /// locale, so this deliberately does **not** follow an ambient RTL
  /// [Directionality], because otherwise the seconds would appear where the
  /// hours belong. Labels themselves are ordinary strings and render in whatever
  /// language you pass. Set this explicitly if you really want the segments
  /// mirrored.
  final TextDirection textDirection;

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
  Widget build(BuildContext context) {
    return FlipCountdownBuilder(
      controller: controller,
      duration: duration,
      targetDate: targetDate,
      referenceTime: referenceTime,
      autoStart: autoStart,
      onDone: onDone,
      onTick: onTick,
      builder: (context, remaining, status) {
        if (status == FlipCountdownStatus.completed &&
            completedBuilder != null) {
          return completedBuilder!(context);
        }
        return _buildSegments(context, remaining);
      },
    );
  }

  bool _daysVisible(Duration remaining) =>
      showDays ?? remaining.inDays > 0;

  bool _hoursVisible(Duration remaining) =>
      showHours ?? (_daysVisible(remaining) || remaining.inHours > 0);

  Widget _buildSegments(BuildContext context, Duration remaining) {
    final resolved = effectiveStyle;
    final days = _daysVisible(remaining);
    final hours = _hoursVisible(remaining);

    final segments = <Widget>[];

    void addSegment(int value, String label) {
      if (segments.isNotEmpty) segments.add(_buildSeparator(resolved));
      segments.add(_buildSegment(value, label, resolved));
    }

    if (days) addSegment(remaining.inDays, labels.days);
    if (hours) {
      addSegment(
        days ? remaining.inHours.remainder(24) : remaining.inHours,
        labels.hours,
      );
    }
    if (showMinutes) {
      addSegment(remaining.inMinutes.remainder(60), labels.minutes);
    }
    if (showSeconds) {
      addSegment(remaining.inSeconds.remainder(60), labels.seconds);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      // A captioned segment is taller than a bare separator, so centring the
      // row would float the separator away from the digits. Align to the edge
      // the digits actually sit on.
      textDirection: textDirection,
      crossAxisAlignment: !showLabels
          ? CrossAxisAlignment.center
          : labelPosition == FlipLabelPosition.above
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: segments,
    );
  }

  Widget _buildSegment(int value, String label, FlipDigitStyle resolved) {
    final digits = FlipNumber(
      value: value,
      minDigits: 2,
      style: resolved,
      digitBuilder: digitBuilder,
      duration: flipDuration,
      direction: direction,
      spacing: panelSpacing,
      digitSpacing: spacing,
      curve: curve,
    );

    if (!showLabels) return digits;

    final caption = Text(
      label,
      style: labelStyle ??
          TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: resolved.backgroundColor,
          ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: labelPosition == FlipLabelPosition.above
          ? [caption, SizedBox(height: labelSpacing), digits]
          : [digits, SizedBox(height: labelSpacing), caption],
    );
  }

  Widget _buildSeparator(FlipDigitStyle resolved) {
    final child = separator ??
        Container(
          width: resolved.width / 2,
          height: resolved.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: resolved.gradient == null ? resolved.backgroundColor : null,
            gradient: resolved.gradient,
            borderRadius: resolved.borderRadius,
          ),
          child: Text(
            ':',
            // Inherit the digits' weight, family and spacing so the separator
            // does not look like it came from a different typeface.
            style: resolved.resolveTextStyle().copyWith(height: 1.0),
          ),
        );

    return Padding(padding: spacing, child: child);
  }
}
