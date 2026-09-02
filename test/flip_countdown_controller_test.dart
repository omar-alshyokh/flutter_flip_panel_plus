import 'package:fake_async/fake_async.dart';
import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fixed point far from the machine's real clock, so any accidental use of
/// the real clock shows up as an obvious failure.
final DateTime _base = DateTime(2035, 1, 1, 12, 0, 0);

void main() {
  group('FlipCountdownController', () {
    test('starts running and counts down', () {
      fakeAsync((async) {
        final controller = FlipCountdownController(
          duration: const Duration(seconds: 10),
          now: () => _base.add(async.elapsed),
        );

        expect(controller.status, FlipCountdownStatus.running);
        expect(controller.remaining, const Duration(seconds: 10));

        async.elapse(const Duration(seconds: 3));
        expect(controller.remaining, const Duration(seconds: 7));

        controller.dispose();
      });
    });

    test('does not auto start when autoStart is false', () {
      fakeAsync((async) {
        final controller = FlipCountdownController(
          duration: const Duration(seconds: 5),
          autoStart: false,
          now: () => _base.add(async.elapsed),
        );

        expect(controller.status, FlipCountdownStatus.idle);
        async.elapse(const Duration(seconds: 3));
        expect(controller.remaining, const Duration(seconds: 5));

        controller.start();
        async.elapse(const Duration(seconds: 2));
        expect(controller.remaining, const Duration(seconds: 3));

        controller.dispose();
      });
    });

    test('completes at zero, announced once, never negative', () {
      fakeAsync((async) {
        var completions = 0;
        final controller = FlipCountdownController(
          duration: const Duration(seconds: 2),
          now: () => _base.add(async.elapsed),
        );
        controller.addListener(() {
          if (controller.isCompleted) completions++;
        });

        async.elapse(const Duration(seconds: 10));

        expect(controller.remaining, Duration.zero);
        expect(controller.status, FlipCountdownStatus.completed);
        expect(completions, 1);

        controller.dispose();
      });
    });

    test('pause holds the remaining time, resume continues', () {
      fakeAsync((async) {
        final controller = FlipCountdownController(
          duration: const Duration(seconds: 10),
          now: () => _base.add(async.elapsed),
        );

        async.elapse(const Duration(seconds: 3));
        controller.pause();
        expect(controller.status, FlipCountdownStatus.paused);

        final held = controller.remaining;
        async.elapse(const Duration(seconds: 5));
        expect(controller.remaining, held, reason: 'paused must not tick');

        controller.resume();
        async.elapse(const Duration(seconds: 2));
        expect(controller.remaining, const Duration(seconds: 5));

        controller.dispose();
      });
    });

    test('reset returns to the initial duration', () {
      fakeAsync((async) {
        final controller = FlipCountdownController(
          duration: const Duration(seconds: 10),
          now: () => _base.add(async.elapsed),
        );

        async.elapse(const Duration(seconds: 4));
        controller.reset();

        expect(controller.status, FlipCountdownStatus.idle);
        expect(controller.remaining, const Duration(seconds: 10));

        controller.reset(duration: const Duration(seconds: 30));
        expect(controller.remaining, const Duration(seconds: 30));

        controller.dispose();
      });
    });

    test('addTime extends a running countdown', () {
      fakeAsync((async) {
        final controller = FlipCountdownController(
          duration: const Duration(seconds: 10),
          now: () => _base.add(async.elapsed),
        );

        async.elapse(const Duration(seconds: 4));
        controller.addTime(const Duration(seconds: 5));

        expect(controller.remaining, const Duration(seconds: 11));

        controller.dispose();
      });
    });

    test('addTime restarts a completed countdown', () {
      fakeAsync((async) {
        final controller = FlipCountdownController(
          duration: const Duration(seconds: 2),
          now: () => _base.add(async.elapsed),
        );

        async.elapse(const Duration(seconds: 5));
        expect(controller.isCompleted, isTrue);

        controller.addTime(const Duration(seconds: 10));
        expect(controller.status, FlipCountdownStatus.running);
        expect(controller.remaining, greaterThan(Duration.zero));

        controller.dispose();
      });
    });

    test('targetDate is measured against referenceTime, not the device clock',
        () {
      fakeAsync((async) {
        final reference = DateTime(2035, 6, 1, 8, 0, 0);
        final target = reference.add(const Duration(minutes: 5));

        final controller = FlipCountdownController(
          targetDate: target,
          referenceTime: reference,
          now: () => _base.add(async.elapsed),
        );

        expect(controller.remaining, const Duration(minutes: 5));

        async.elapse(const Duration(minutes: 1));
        expect(controller.remaining, const Duration(minutes: 4));

        controller.dispose();
      });
    });

    test('a target already in the past completes immediately', () {
      fakeAsync((async) {
        final reference = DateTime(2035, 6, 1, 8, 0, 0);
        final controller = FlipCountdownController(
          targetDate: reference.subtract(const Duration(hours: 1)),
          referenceTime: reference,
          now: () => _base.add(async.elapsed),
        );

        expect(controller.remaining, Duration.zero);
        expect(controller.status, FlipCountdownStatus.completed);

        controller.dispose();
      });
    });

    test('does not drift when the app is suspended and ticks are missed', () {
      fakeAsync((async) {
        final controller = FlipCountdownController(
          duration: const Duration(seconds: 60),
          now: () => _base.add(async.elapsed),
        );

        // Jump forward in one go, as if the app had been backgrounded.
        async.elapse(const Duration(seconds: 45));

        // Derived from time actually passed, not from counting ticks.
        expect(controller.remaining, const Duration(seconds: 15));

        controller.dispose();
      });
    });

    test('cannot be rewound by moving the device clock backwards', () {
      fakeAsync((async) {
        // A clock the test can shove backwards mid-countdown.
        var offset = Duration.zero;
        final controller = FlipCountdownController(
          duration: const Duration(minutes: 10),
          now: () => _base.add(async.elapsed + offset),
        );

        async.elapse(const Duration(minutes: 3));
        final before = controller.remaining;
        expect(before, const Duration(minutes: 7));

        // The user winds the clock back an hour.
        offset = const Duration(hours: -1);
        async.elapse(const Duration(seconds: 1));

        expect(
          controller.remaining,
          lessThanOrEqualTo(before),
          reason: 'a backwards clock must never add time back',
        );

        controller.dispose();
      });
    });

    test('is inert after dispose', () {
      fakeAsync((async) {
        final controller = FlipCountdownController(
          duration: const Duration(seconds: 10),
          now: () => _base.add(async.elapsed),
        );
        controller.dispose();

        // Must not throw and must not schedule further work.
        controller.start();
        controller.pause();
        async.elapse(const Duration(seconds: 5));
      });
    });

    test('rejects conflicting or missing configuration', () {
      expect(FlipCountdownController.new, throwsAssertionError);
      expect(
        () => FlipCountdownController(
          duration: const Duration(seconds: 1),
          targetDate: DateTime(2035),
        ),
        throwsAssertionError,
      );
      expect(
        () => FlipCountdownController(duration: const Duration(seconds: -1)),
        throwsAssertionError,
      );
    });
  });
}
