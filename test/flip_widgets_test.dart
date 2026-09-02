import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('FlipDigit', () {
    testWidgets('renders its value', (tester) async {
      await tester.pumpWidget(_wrap(const FlipDigit(value: 7)));
      expect(find.text('7'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('flips to a new value without throwing', (tester) async {
      await tester.pumpWidget(_wrap(const FlipDigit(value: 1)));
      expect(find.text('1'), findsWidgets);

      await tester.pumpWidget(_wrap(const FlipDigit(value: 2)));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('2'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('FlipNumber', () {
    testWidgets('pads to minDigits', (tester) async {
      await tester.pumpWidget(_wrap(const FlipNumber(value: 7, minDigits: 3)));
      // 007 -> two zeros and a seven.
      expect(find.text('0'), findsWidgets);
      expect(find.text('7'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('shows a value wider than minDigits', (tester) async {
      await tester.pumpWidget(_wrap(const FlipNumber(value: 123, minDigits: 2)));
      expect(find.text('1'), findsWidgets);
      expect(find.text('2'), findsWidgets);
      expect(find.text('3'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('FlipCountdown', () {
    testWidgets('renders and reports ticks', (tester) async {
      final ticks = <Duration>[];

      await tester.pumpWidget(_wrap(
        FlipCountdown(
          duration: const Duration(seconds: 5),
          onTick: ticks.add,
        ),
      ));

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(ticks, isNotEmpty);
      expect(ticks.last, lessThan(const Duration(seconds: 5)));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('calls onDone exactly once', (tester) async {
      var done = 0;

      await tester.pumpWidget(_wrap(
        FlipCountdown(
          duration: const Duration(seconds: 2),
          onDone: () => done++,
        ),
      ));

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(done, 1);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('does not dispose a controller it does not own',
        (tester) async {
      final controller = FlipCountdownController(
        duration: const Duration(seconds: 30),
      );

      await tester.pumpWidget(_wrap(FlipCountdown(controller: controller)));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox());

      // Still usable after the widget is gone.
      expect(() => controller.pause(), returnsNormally);
      expect(controller.status, isNot(FlipCountdownStatus.running));
      controller.dispose();
    });

    testWidgets('hides the days segment for a short countdown',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FlipCountdown(
          duration: const Duration(minutes: 5),
          showLabels: true,
        ),
      ));

      expect(find.text('DAYS'), findsNothing);
      expect(find.text('MINUTES'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('shows the days segment for a long countdown', (tester) async {
      await tester.pumpWidget(_wrap(
        FlipCountdown(
          duration: const Duration(days: 2),
          showLabels: true,
        ),
      ));

      expect(find.text('DAYS'), findsOneWidget);
      expect(find.text('HOURS'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('FlipClockPlus', () {
    testWidgets('countdown renders', (tester) async {
      await tester.pumpWidget(_wrap(
        FlipClockPlus.countdown(
          duration: const Duration(seconds: 30),
          digitColor: Colors.white,
          backgroundColor: Colors.black,
          digitSize: 20,
        ),
      ));

      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    // Regression: the countdown used to build a fresh periodic stream on every
    // build, so any parent rebuild silently restarted it.
    testWidgets('a parent rebuild does not restart the countdown',
        (tester) async {
      var done = 0;
      final rebuild = ValueNotifier<int>(0);

      await tester.pumpWidget(_wrap(
        ValueListenableBuilder<int>(
          valueListenable: rebuild,
          builder: (context, value, _) => Column(
            children: [
              Text('build $value'),
              FlipClockPlus.countdown(
                duration: const Duration(seconds: 3),
                digitColor: Colors.white,
                backgroundColor: Colors.black,
                digitSize: 20,
                onDone: () => done++,
              ),
            ],
          ),
        ),
      ));

      await tester.pump(const Duration(seconds: 1));

      // Force rebuilds part way through.
      rebuild.value = 1;
      await tester.pump();
      rebuild.value = 2;
      await tester.pump();

      // Total elapsed is now past the original three seconds.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(done, 1, reason: 'the countdown should finish on its own schedule');

      await tester.pumpWidget(const SizedBox());
      rebuild.dispose();
    });
  });
}
