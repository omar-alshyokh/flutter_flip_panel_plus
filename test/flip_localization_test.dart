import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _rtl(Widget child) => MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: Center(child: child)),
      ),
    );

Widget _ltr(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

const _arabic = FlipCountdownLabels(
  days: 'أيام',
  hours: 'ساعات',
  minutes: 'دقائق',
  seconds: 'ثوانٍ',
);

void main() {
  group('labels are free text', () {
    testWidgets('renders Arabic captions', (tester) async {
      await tester.pumpWidget(_rtl(
        const FlipCountdown(
          duration: Duration(hours: 2, minutes: 34),
          showLabels: true,
          labels: _arabic,
        ),
      ));

      expect(find.text('ساعات'), findsOneWidget);
      expect(find.text('دقائق'), findsOneWidget);
      expect(find.text('ثوانٍ'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('renders any other language', (tester) async {
      await tester.pumpWidget(_ltr(
        const FlipCountdown(
          duration: Duration(minutes: 5),
          showLabels: true,
          labels: FlipCountdownLabels(
            minutes: 'Minuten',
            seconds: 'Sekunden',
          ),
        ),
      ));

      expect(find.text('Minuten'), findsOneWidget);
      expect(find.text('Sekunden'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('segment order under RTL', () {
    // A clock reads left to right in every locale. Following an ambient RTL
    // Directionality would put the seconds where the hours belong.
    testWidgets('stays left to right inside an RTL app', (tester) async {
      await tester.pumpWidget(_rtl(
        const FlipCountdown(
          duration: Duration(hours: 2, minutes: 34, seconds: 56),
        ),
      ));

      final hours = tester.getRect(find.text('2').first).center.dx;
      final seconds = tester.getRect(find.text('6').first).center.dx;

      expect(hours, lessThan(seconds),
          reason: 'hours must stay on the left of seconds');

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('FlipClockPlus also stays left to right', (tester) async {
      await tester.pumpWidget(_rtl(
        FlipClockPlus.countdown(
          duration: const Duration(hours: 2, minutes: 34, seconds: 56),
          digitColor: Colors.white,
          backgroundColor: Colors.black,
          digitSize: 18,
        ),
      ));

      final hours = tester.getRect(find.text('2').first).center.dx;
      final seconds = tester.getRect(find.text('6').first).center.dx;
      expect(hours, lessThan(seconds));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('can be mirrored on request', (tester) async {
      await tester.pumpWidget(_ltr(
        const FlipCountdown(
          duration: Duration(hours: 2, minutes: 34, seconds: 56),
          textDirection: TextDirection.rtl,
        ),
      ));

      final hours = tester.getRect(find.text('2').first).center.dx;
      final seconds = tester.getRect(find.text('6').first).center.dx;
      expect(hours, greaterThan(seconds),
          reason: 'an explicit rtl request should mirror the segments');

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('numeral systems', () {
    test('easternArabicNumerals maps every digit', () {
      expect(FlipDigitStyle.easternArabicNumerals(0), '٠');
      expect(FlipDigitStyle.easternArabicNumerals(5), '٥');
      expect(FlipDigitStyle.easternArabicNumerals(9), '٩');
      expect(FlipDigitStyle.easternArabicNumerals(12), '١٢');
    });

    testWidgets('digits render in Eastern Arabic numerals', (tester) async {
      await tester.pumpWidget(_rtl(
        FlipCountdown(
          duration: const Duration(minutes: 12, seconds: 34),
          showLabels: true,
          labels: _arabic,
          style: const FlipDigitStyle.dark().copyWith(
            digitFormatter: FlipDigitStyle.easternArabicNumerals,
          ),
        ),
      ));

      // 12:34 -> ١٢:٣٤
      expect(find.text('١'), findsWidgets);
      expect(find.text('٢'), findsWidgets);
      expect(find.text('٣'), findsWidgets);
      expect(find.text('٤'), findsWidgets);
      expect(find.text('1'), findsNothing);

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('digit order within a number', () {
    // 12 must render as "1" then "2" even inside an RTL app, otherwise an
    // Eastern Arabic 12 (١٢) would be shown as 21 (٢١).
    testWidgets('does not reverse under RTL', (tester) async {
      await tester.pumpWidget(_rtl(
        const FlipCountdown(
          duration: Duration(minutes: 12),
          showSeconds: false,
          showHours: false,
        ),
      ));

      final one = tester.getRect(find.text('1').first).center.dx;
      final two = tester.getRect(find.text('2').first).center.dx;

      expect(one, lessThan(two),
          reason: '12 must not be rendered as 21');

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('FlipNumber does not reverse under RTL', (tester) async {
      await tester.pumpWidget(_rtl(const FlipNumber(value: 12)));

      final one = tester.getRect(find.text('1').first).center.dx;
      final two = tester.getRect(find.text('2').first).center.dx;
      expect(one, lessThan(two));

      await tester.pumpWidget(const SizedBox());
    });
  });
}
