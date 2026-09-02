import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

/// The lifecycle of a [FlipCountdownController].
enum FlipCountdownStatus {
  /// Created but not started, or reset back to its initial value.
  idle,

  /// Counting down.
  running,

  /// Paused part way through. [FlipCountdownController.remaining] is held.
  paused,

  /// Reached zero.
  completed,
}

/// Drives a countdown and notifies listeners once per tick.
///
/// The time remaining is *derived* from how much time has actually passed,
/// never by subtracting a fixed amount on each tick. Two independent clocks are
/// read and the larger elapsed value wins:
///
/// * a monotonic [Stopwatch], which cannot be moved backwards, and
/// * the wall clock, which keeps counting while the device is asleep.
///
/// Taking the larger of the two gives behaviour that is correct in the cases
/// that actually bite:
///
/// * **Dropped or late ticks** (a busy frame, a slow build) cannot make the
///   countdown drift, because the value is recomputed rather than decremented.
/// * **The app is backgrounded or the device sleeps.** A monotonic clock can
///   stall while suspended; the wall clock catches the countdown back up.
/// * **The device clock is moved backwards**, by the user or by an NTP
///   correction. The monotonic floor prevents the countdown from rewinding.
///
/// Create one with a [duration], or with a [targetDate] and an optional
/// [referenceTime]. Passing [referenceTime] is the recommended way to run a
/// countdown against a server clock: hand it the server's "now" and the
/// device's own clock is never used to decide how long is left.
///
/// ```dart
/// final controller = FlipCountdownController(
///   targetDate: saleEndsAt,
///   referenceTime: serverNow, // optional, from your API
/// );
/// ```
///
/// Dispose the controller when you created it yourself.
class FlipCountdownController extends ChangeNotifier {
  /// Creates a countdown.
  ///
  /// Provide exactly one of [duration] or [targetDate].
  ///
  /// * [duration] counts down that long from the moment it starts.
  /// * [targetDate] counts down until that moment, measured against
  ///   [referenceTime] (defaulting to the current time).
  ///
  /// If [autoStart] is true the countdown begins immediately.
  FlipCountdownController({
    Duration? duration,
    DateTime? targetDate,
    DateTime? referenceTime,
    this.tickInterval = const Duration(seconds: 1),
    bool autoStart = true,
    @visibleForTesting DateTime Function()? now,
  })  : assert(duration != null || targetDate != null,
            'Provide either a duration or a targetDate.'),
        assert(duration == null || targetDate == null,
            'Provide only one of duration or targetDate, not both.'),
        assert(duration == null || !duration.isNegative,
            'duration must not be negative.'),
        assert(tickInterval > Duration.zero,
            'tickInterval must be greater than zero.'),
        _now = now ?? _defaultNow {
    _initial = duration ?? _durationUntil(targetDate!, referenceTime, _now);
    _remaining = _initial;
    if (autoStart) start();
  }

  /// How often listeners are notified. Defaults to one second.
  final Duration tickInterval;

  final DateTime Function() _now;

  /// Reads the wall clock through `package:clock`, so tests (and callers using
  /// `withClock`) can control time without touching the widget tree.
  static DateTime _defaultNow() => clock.now();

  /// Monotonic floor: cannot be moved backwards by a clock change.
  final Stopwatch _stopwatch = Stopwatch();

  /// Wall-clock elapsed time banked from previous running stretches.
  Duration _wallBanked = Duration.zero;

  /// When the current running stretch began, on the wall clock.
  DateTime? _wallResumedAt;

  /// Highest elapsed value seen so far; elapsed time never goes down.
  Duration _elapsedFloor = Duration.zero;

  Timer? _timer;
  bool _disposed = false;

  late Duration _initial;
  late Duration _remaining;
  FlipCountdownStatus _status = FlipCountdownStatus.idle;

  static Duration _durationUntil(
    DateTime target,
    DateTime? reference,
    DateTime Function() now,
  ) {
    final left = target.difference(reference ?? now());
    return left.isNegative ? Duration.zero : left;
  }

  /// The time the countdown started from.
  Duration get initialDuration => _initial;

  /// Time left, never negative.
  Duration get remaining => _remaining;

  /// The current lifecycle state.
  FlipCountdownStatus get status => _status;

  /// Whether the countdown has reached zero.
  bool get isCompleted => _status == FlipCountdownStatus.completed;

  /// Whether the countdown is currently ticking.
  bool get isRunning => _status == FlipCountdownStatus.running;

  /// How much of the countdown has elapsed, from 0.0 to 1.0.
  double get progress {
    if (_initial == Duration.zero) return 1.0;
    final done = _initial.inMicroseconds - _remaining.inMicroseconds;
    return (done / _initial.inMicroseconds).clamp(0.0, 1.0);
  }

  /// Elapsed time, taken as the larger of the monotonic and wall-clock
  /// measurements and ratcheted so it can never decrease. See the class
  /// documentation for why.
  Duration _computeElapsed() {
    var wall = _wallBanked;
    final resumedAt = _wallResumedAt;
    if (resumedAt != null) {
      final since = _now().difference(resumedAt);
      // A negative delta means the clock moved backwards; ignore it.
      if (!since.isNegative) wall += since;
    }
    final monotonic = _stopwatch.elapsed;
    final candidate = monotonic > wall ? monotonic : wall;
    if (candidate > _elapsedFloor) _elapsedFloor = candidate;
    return _elapsedFloor;
  }

  /// Starts the countdown. Does nothing if it is already running or completed.
  void start() {
    if (_disposed) return;
    if (_status == FlipCountdownStatus.running) return;
    if (_status == FlipCountdownStatus.completed) return;
    if (_initial == Duration.zero) {
      _complete();
      return;
    }

    _status = FlipCountdownStatus.running;
    _stopwatch.start();
    _wallResumedAt = _now();
    _scheduleTimer();
    _notify();
  }

  /// Pauses the countdown, holding [remaining] where it is.
  void pause() {
    if (_disposed || _status != FlipCountdownStatus.running) return;
    _bankWallTime();
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;
    _status = FlipCountdownStatus.paused;
    _notify();
  }

  /// Resumes a paused countdown.
  void resume() {
    if (_disposed || _status != FlipCountdownStatus.paused) return;
    _status = FlipCountdownStatus.running;
    _stopwatch.start();
    _wallResumedAt = _now();
    _scheduleTimer();
    _notify();
  }

  /// Stops and returns to the starting value.
  ///
  /// Pass [duration] to reset to a different length. If [autoStart] is true the
  /// countdown starts again immediately.
  void reset({Duration? duration, bool autoStart = false}) {
    if (_disposed) return;
    _timer?.cancel();
    _timer = null;
    _stopwatch
      ..stop()
      ..reset();
    _wallBanked = Duration.zero;
    _wallResumedAt = null;
    _elapsedFloor = Duration.zero;
    if (duration != null) _initial = duration;
    _remaining = _initial;
    _status = FlipCountdownStatus.idle;
    _notify();
    if (autoStart) start();
  }

  /// Adds time to the countdown.
  ///
  /// Useful for "extended by 5 minutes" behaviour. A negative [extra] shortens
  /// the countdown and may complete it immediately. Extending a countdown that
  /// has already finished restarts it.
  void addTime(Duration extra) {
    if (_disposed) return;
    _initial += extra;
    if (_initial.isNegative) _initial = Duration.zero;

    if (_status == FlipCountdownStatus.completed && _initial > _computeElapsed()) {
      _status = FlipCountdownStatus.paused;
      resume();
      // Refresh straight away rather than waiting for the next tick.
      _syncRemaining();
      return;
    }
    _syncRemaining();
  }

  void _bankWallTime() {
    final resumedAt = _wallResumedAt;
    if (resumedAt == null) return;
    final since = _now().difference(resumedAt);
    if (!since.isNegative) _wallBanked += since;
    _wallResumedAt = null;
  }

  void _scheduleTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(tickInterval, (_) => _syncRemaining());
  }

  void _syncRemaining() {
    if (_disposed) return;
    final left = _initial - _computeElapsed();
    _remaining = left.isNegative ? Duration.zero : left;
    if (_remaining == Duration.zero) {
      _complete();
    } else {
      _notify();
    }
  }

  void _complete() {
    _timer?.cancel();
    _timer = null;
    _bankWallTime();
    _stopwatch.stop();
    _remaining = Duration.zero;
    if (_status != FlipCountdownStatus.completed) {
      _status = FlipCountdownStatus.completed;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
    super.dispose();
  }
}
