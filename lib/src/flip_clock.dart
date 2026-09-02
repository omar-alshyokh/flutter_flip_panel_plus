import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

import 'countdown/flip_countdown_controller.dart';

import 'flip_digit.dart';
import 'flip_direction.dart';
import 'typedefs.dart';

/// A flip clock, or a flip countdown when [countdownMode] is enabled.
///
/// Countdown timing is delegated to [FlipCountdownController], so a rebuild of
/// the parent no longer restarts the clock, a late tick cannot cause drift, and
/// the countdown stays correct across device sleep and clock changes.
///
/// Segments can be hidden individually with [showHours], [showMinutes] and
/// [showSeconds].
///
/// For new code prefer [FlipCountdown], which adds pause/resume/reset through a
/// controller, can count down to a `DateTime`, and takes a [FlipDigitStyle].
class FlipClockPlus extends StatefulWidget {
  /// Creates a fully custom flip clock.
  const FlipClockPlus({
    super.key,
    required DigitBuilder digitBuilder,
    required Widget separator,
    required this.startTime,
    this.countdownMode = false,
    this.spacing = const EdgeInsets.symmetric(horizontal: 2.0),
    this.flipDirection = FlipDirection.down,
    this.height = 44.0,
    this.width = 60.0,
    this.centerGapSpace = 0.0,
    this.timeLeft,
    this.showMinutes = true,
    this.showSeconds = true,
    String? daysLabelStr,
    String? hoursLabelStr,
    String? minutesLabelStr,
    String? secondsLabelStr,
  })  : showHours = true,
        showDays = false,
        onDone = null,
        _digitBuilder = digitBuilder,
        _separator = separator,
        _daysLabelStr = daysLabelStr,
        _hoursLabelStr = hoursLabelStr,
        _minutesLabelStr = minutesLabelStr,
        _secondsLabelStr = secondsLabelStr;

  /// A clock showing the current time, styled by colour and size.
  FlipClockPlus.simple({
    super.key,
    required this.startTime,
    required Color digitColor,
    required Color backgroundColor,
    required double digitSize,
    Widget? separator,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(0.0)),
    this.spacing = const EdgeInsets.symmetric(horizontal: 2.0),
    this.flipDirection = FlipDirection.down,
    this.height = 60.0,
    this.width = 44.0,
    this.centerGapSpace = 0.0,
    this.timeLeft,
    this.showHours = true,
    this.showMinutes = true,
    this.showSeconds = true,
  })  : countdownMode = false,
        showDays = false,
        onDone = null,
        _daysLabelStr = null,
        _hoursLabelStr = null,
        _minutesLabelStr = null,
        _secondsLabelStr = null,
        _digitBuilder = defaultDigitBuilder(
          digitColor: digitColor,
          backgroundColor: backgroundColor,
          digitSize: digitSize,
          width: width,
          height: height,
          borderRadius: borderRadius,
        ),
        _separator = separator ??
            _defaultSeparator(
              digitColor: digitColor,
              backgroundColor: backgroundColor,
              digitSize: digitSize,
              width: width,
              height: height,
              borderRadius: borderRadius,
            );

  /// A countdown of [duration], showing hours, minutes and seconds.
  FlipClockPlus.countdown({
    super.key,
    required Duration duration,
    required Color digitColor,
    required Color backgroundColor,
    required double digitSize,
    Widget? separator,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(0.0)),
    this.spacing = const EdgeInsets.symmetric(horizontal: 2.0),
    this.onDone,
    this.flipDirection = FlipDirection.down,
    this.height = 60.0,
    this.width = 44.0,
    this.centerGapSpace = 0.0,
    bool? showHours,
    this.showMinutes = true,
    this.showSeconds = true,
  })  : countdownMode = true,
        startTime = DateTime.now(),
        timeLeft = duration,
        showHours = showHours ?? duration.inHours > 0,
        showDays = false,
        _daysLabelStr = null,
        _hoursLabelStr = null,
        _minutesLabelStr = null,
        _secondsLabelStr = null,
        _digitBuilder = defaultDigitBuilder(
          digitColor: digitColor,
          backgroundColor: backgroundColor,
          digitSize: digitSize,
          width: width,
          height: height,
          borderRadius: borderRadius,
        ),
        _separator = separator ??
            _defaultSeparator(
              digitColor: digitColor,
              backgroundColor: backgroundColor,
              digitSize: digitSize,
              width: width,
              height: height,
              borderRadius: borderRadius,
            );

  /// A countdown that also shows days, with a caption under each segment.
  FlipClockPlus.reverseCountdown({
    super.key,
    required Duration duration,
    required Color digitColor,
    required Color backgroundColor,
    required double digitSize,
    Widget? separator,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(0.0)),
    this.spacing = const EdgeInsets.symmetric(horizontal: 2.0),
    this.onDone,
    this.flipDirection = FlipDirection.down,
    this.height = 40.0,
    this.width = 24.0,
    this.centerGapSpace = 0.0,
    this.showMinutes = true,
    this.showSeconds = true,
    String? daysLabelStr,
    String? hoursLabelStr,
    String? minutesLabelStr,
    String? secondsLabelStr,
  })  : countdownMode = true,
        startTime = DateTime.now(),
        timeLeft = duration,
        showHours = true,
        showDays = true,
        _daysLabelStr = daysLabelStr,
        _hoursLabelStr = hoursLabelStr,
        _minutesLabelStr = minutesLabelStr,
        _secondsLabelStr = secondsLabelStr,
        _digitBuilder = defaultDigitBuilder(
          digitColor: digitColor,
          backgroundColor: backgroundColor,
          digitSize: digitSize,
          width: width,
          height: height,
          borderRadius: borderRadius,
        ),
        _separator = separator ??
            _defaultSeparator(
              digitColor: digitColor,
              backgroundColor: backgroundColor,
              digitSize: digitSize,
              width: width,
              height: height,
              borderRadius: borderRadius,
            );

  final DigitBuilder _digitBuilder;
  final Widget _separator;
  final String? _daysLabelStr;
  final String? _hoursLabelStr;
  final String? _minutesLabelStr;
  final String? _secondsLabelStr;

  /// The moment the clock starts from.
  final DateTime startTime;

  /// Whether this counts down rather than showing the time of day.
  final bool countdownMode;

  /// Whether the hours segment is shown.
  final bool showHours;

  /// Whether the days segment (and captions) are shown.
  final bool showDays;

  /// Whether the minutes segment is shown.
  final bool showMinutes;

  /// Whether the seconds segment is shown.
  final bool showSeconds;

  /// How long the countdown runs for. Only used when [countdownMode] is true.
  final Duration? timeLeft;

  /// Called when a countdown reaches zero.
  final VoidCallback? onDone;

  final EdgeInsets spacing;
  final FlipDirection flipDirection;
  final double height;
  final double width;

  /// Vertical gap between the two halves of each digit.
  final double centerGapSpace;

  static Widget _defaultSeparator({
    required Color digitColor,
    required Color backgroundColor,
    required double digitSize,
    required double width,
    required double height,
    required BorderRadius borderRadius,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        width: width / 2,
        height: height,
        alignment: Alignment.center,
        child: Text(
          ':',
          // Matches the digits, which are bold.
          style: TextStyle(
            fontSize: digitSize,
            fontWeight: FontWeight.bold,
            color: digitColor,
            height: 1.0,
          ),
        ),
      );

  @override
  State<FlipClockPlus> createState() => _FlipClockPlusState();
}

class _FlipClockPlusState extends State<FlipClockPlus> {
  /// Countdown mode delegates its timing to the shared controller, so it gets
  /// the same protection against drift, suspension and clock changes.
  FlipCountdownController? _countdown;

  /// Clock mode ticks off the wall clock, read through `package:clock`.
  Timer? _timer;
  late DateTime _startedAt;

  bool _doneFired = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _doneFired = false;
    _disposeTiming();
    _startedAt = clock.now();

    if (widget.countdownMode) {
      _countdown = FlipCountdownController(
        duration: widget.timeLeft ?? Duration.zero,
      )..addListener(_handleCountdown);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _handleCountdown() {
    if (!mounted) return;
    setState(() {});
    final controller = _countdown;
    if (controller != null && controller.isCompleted && !_doneFired) {
      _doneFired = true;
      widget.onDone?.call();
    }
  }

  void _disposeTiming() {
    _timer?.cancel();
    _timer = null;
    _countdown?.removeListener(_handleCountdown);
    _countdown?.dispose();
    _countdown = null;
  }

  @override
  void didUpdateWidget(covariant FlipClockPlus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeLeft != widget.timeLeft ||
        oldWidget.startTime != widget.startTime ||
        oldWidget.countdownMode != widget.countdownMode) {
      _start();
    }
  }

  @override
  void dispose() {
    _disposeTiming();
    super.dispose();
  }

  /// Time left in countdown mode, never negative.
  Duration get _remaining => _countdown?.remaining ?? Duration.zero;

  /// The displayed time in clock mode.
  DateTime get _now =>
      widget.startTime.add(clock.now().difference(_startedAt));

  @override
  Widget build(BuildContext context) {
    final countdown = widget.countdownMode;
    final remaining = _remaining;
    final now = _now;

    final segments = <Widget>[];

    void addSegment(int value, String label) {
      if (segments.isNotEmpty) segments.add(_buildSeparator());
      segments.add(_buildSegment(value, label));
    }

    if (widget.showDays) {
      addSegment(remaining.inDays, widget._daysLabelStr ?? 'days');
    }
    if (widget.showHours) {
      addSegment(
        countdown ? remaining.inHours.remainder(24) : now.hour,
        widget._hoursLabelStr ?? 'Hours',
      );
    }
    if (widget.showMinutes) {
      addSegment(
        countdown ? remaining.inMinutes.remainder(60) : now.minute,
        widget._minutesLabelStr ?? 'minutes',
      );
    }
    if (widget.showSeconds) {
      addSegment(
        countdown ? remaining.inSeconds.remainder(60) : now.second,
        widget._secondsLabelStr ?? 'seconds',
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      // A clock reads left to right in every locale, so the segment order is
      // fixed rather than following an ambient RTL Directionality.
      textDirection: TextDirection.ltr,
      crossAxisAlignment: widget.showDays
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: segments,
    );
  }

  Widget _buildSegment(int value, String label) {
    final digits = Row(
      mainAxisSize: MainAxisSize.min,
      // Digits within a number always read left to right.
      textDirection: TextDirection.ltr,
      children: [
        for (final digit in _twoDigits(value))
          Padding(
            padding: widget.spacing,
            child: FlipDigit(
              value: digit,
              digitBuilder: widget._digitBuilder,
              duration: const Duration(milliseconds: 450),
              direction: widget.flipDirection,
              spacing: widget.centerGapSpace,
            ),
          ),
      ],
    );

    if (!widget.showDays || label.isEmpty) return digits;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        digits,
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3.0),
            child: Container(
              decoration: const BoxDecoration(color: Colors.black),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Splits a value into its tens and ones digits, growing past 99 rather than
  /// clamping the way earlier versions did.
  List<int> _twoDigits(int value) {
    final safe = value < 0 ? 0 : value;
    final text = safe.toString().padLeft(2, '0');
    return [for (final c in text.split('')) int.parse(c)];
  }

  Widget _buildSeparator() {
    final separator = Padding(padding: widget.spacing, child: widget._separator);
    if (!widget.showDays) return separator;
    // Keep the colon level with the digits when captions add height below.
    return Column(mainAxisSize: MainAxisSize.min, children: [separator]);
  }
}
