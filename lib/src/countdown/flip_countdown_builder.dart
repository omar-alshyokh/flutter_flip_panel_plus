import 'package:flutter/widgets.dart';

import 'flip_countdown_controller.dart';

/// Builds a widget from the current state of a countdown.
typedef FlipCountdownWidgetBuilder = Widget Function(
  BuildContext context,
  Duration remaining,
  FlipCountdownStatus status,
);

/// A countdown with no opinion about how it looks.
///
/// This is the whole timing engine — the protection against drift, device
/// sleep and clock changes — exposed as a builder, so any UI can be driven by
/// it, not just flipping digits.
///
/// ```dart
/// FlipCountdownBuilder(
///   targetDate: saleEndsAt,
///   builder: (context, remaining, status) => Text(
///     '${remaining.inMinutes}:${remaining.inSeconds.remainder(60)}',
///   ),
/// )
/// ```
///
/// Owns its controller unless you supply one. A controller you pass in is
/// yours to dispose.
class FlipCountdownBuilder extends StatefulWidget {
  const FlipCountdownBuilder({
    super.key,
    required this.builder,
    this.controller,
    this.duration,
    this.targetDate,
    this.referenceTime,
    this.autoStart = true,
    this.onDone,
    this.onTick,
  }) : assert(
          controller != null || duration != null || targetDate != null,
          'Provide a controller, a duration, or a targetDate.',
        );

  /// Called on every tick with the time left and the current status.
  final FlipCountdownWidgetBuilder builder;

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

  @override
  State<FlipCountdownBuilder> createState() => _FlipCountdownBuilderState();
}

class _FlipCountdownBuilderState extends State<FlipCountdownBuilder> {
  FlipCountdownController? _internal;
  bool _doneNotified = false;

  FlipCountdownController get controller => widget.controller ?? _internal!;

  @override
  void initState() {
    super.initState();
    _createInternalIfNeeded();
    controller.addListener(_handleUpdate);
  }

  void _createInternalIfNeeded() {
    if (widget.controller != null) return;
    _internal = FlipCountdownController(
      duration: widget.duration,
      targetDate: widget.duration == null ? widget.targetDate : null,
      referenceTime: widget.referenceTime,
      autoStart: widget.autoStart,
    );
  }

  void _rebuildController() {
    widget.controller?.removeListener(_handleUpdate);
    _internal?.removeListener(_handleUpdate);
    _internal?.dispose();
    _internal = null;
    _doneNotified = false;
    _createInternalIfNeeded();
    controller.addListener(_handleUpdate);
  }

  @override
  void didUpdateWidget(covariant FlipCountdownBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Swapped between an external and an internal controller.
    if (oldWidget.controller != widget.controller) {
      _rebuildController();
      return;
    }

    // Restart an internally owned countdown when its target changes.
    if (widget.controller == null &&
        (oldWidget.duration != widget.duration ||
            oldWidget.targetDate != widget.targetDate ||
            oldWidget.referenceTime != widget.referenceTime)) {
      _rebuildController();
    }
  }

  void _handleUpdate() {
    if (!mounted) return;
    setState(() {});
    widget.onTick?.call(controller.remaining);
    if (controller.isCompleted && !_doneNotified) {
      _doneNotified = true;
      widget.onDone?.call();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleUpdate);
    _internal?.removeListener(_handleUpdate);
    _internal?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, controller.remaining, controller.status);
}
