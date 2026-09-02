import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

/// The decoration of the first digit box rendered by [finder]'s subtree.
BoxDecoration _firstDigitDecoration(WidgetTester tester) {
  final container = tester.widgetList<Container>(find.byType(Container)).first;
  return container.decoration! as BoxDecoration;
}

void main() {
  group('FlipDigitStyle', () {
    testWidgets('applies a gradient and border radius', (tester) async {
      const gradient = LinearGradient(colors: [Colors.red, Colors.orange]);

      await tester.pumpWidget(_wrap(
        const FlipDigit(
          value: 3,
          style: FlipDigitStyle(
            gradient: gradient,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ));

      final decoration = _firstDigitDecoration(tester);
      expect(decoration.gradient, gradient);
      expect(decoration.color, isNull, reason: 'gradient replaces the colour');
      expect(decoration.borderRadius, BorderRadius.circular(12));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('presets differ from one another', (tester) async {
      const dark = FlipDigitStyle.dark();
      const light = FlipDigitStyle.light();
      const minimal = FlipDigitStyle.minimal();

      expect(dark.backgroundColor, isNot(light.backgroundColor));
      expect(dark.textColor, isNot(light.textColor));
      expect(minimal.backgroundColor, Colors.transparent);
      expect(light.border, isNotNull);
      expect(FlipDigitStyle.card(seed: Colors.indigo).boxShadow, isNotNull);
    });

    test('copyWith replaces only what is given', () {
      const base = FlipDigitStyle.dark(fontSize: 20);
      final copy = base.copyWith(textColor: Colors.amber);

      expect(copy.textColor, Colors.amber);
      expect(copy.fontSize, 20);
      expect(copy.backgroundColor, base.backgroundColor);
      expect(copy, isNot(base));
    });

    test('textStyle merges over the shorthand', () {
      const style = FlipDigitStyle(
        fontSize: 20,
        textColor: Colors.white,
        textStyle: TextStyle(letterSpacing: 3, color: Colors.red),
      );
      final resolved = style.resolveTextStyle();

      expect(resolved.letterSpacing, 3);
      expect(resolved.color, Colors.red, reason: 'textStyle wins');
      expect(resolved.fontSize, 20, reason: 'unset fields fall back');
    });

    testWidgets('style takes precedence over the shorthand properties',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const FlipDigit(
          value: 1,
          backgroundColor: Colors.green, // shorthand, should lose
          style: FlipDigitStyle(backgroundColor: Colors.purple),
        ),
      ));

      expect(_firstDigitDecoration(tester).color, Colors.purple);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('FlipCountdown customization', () {
    testWidgets('completedBuilder replaces the digits at zero',
        (tester) async {
      await tester.pumpWidget(_wrap(
        FlipCountdown(
          duration: const Duration(seconds: 1),
          completedBuilder: (_) => const Text('EXPIRED'),
        ),
      ));

      expect(find.text('EXPIRED'), findsNothing);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('EXPIRED'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('labels can sit above the digits', (tester) async {
      await tester.pumpWidget(_wrap(
        const FlipCountdown(
          duration: Duration(minutes: 3),
          showLabels: true,
          labelPosition: FlipLabelPosition.above,
          labels: FlipCountdownLabels.short(),
        ),
      ));

      expect(find.text('M'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('separator can be removed', (tester) async {
      await tester.pumpWidget(_wrap(
        const FlipCountdown(
          duration: Duration(minutes: 3),
          separator: SizedBox.shrink(),
        ),
      ));

      expect(find.text(':'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('FlipCountdownBuilder', () {
    testWidgets('drives a completely custom UI', (tester) async {
      await tester.pumpWidget(_wrap(
        FlipCountdownBuilder(
          duration: const Duration(seconds: 30),
          builder: (context, remaining, status) =>
              Text('${remaining.inSeconds}s · ${status.name}'),
        ),
      ));

      expect(find.text('30s · running'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      expect(find.text('25s · running'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });

  // Reported as issue #1: a request to hide segments such as the seconds.
  group('segment visibility (issue #1)', () {
    testWidgets('FlipClockPlus.simple can hide seconds', (tester) async {
      await tester.pumpWidget(_wrap(
        FlipClockPlus.simple(
          startTime: DateTime(2035, 1, 1, 10, 30, 45),
          digitColor: Colors.white,
          backgroundColor: Colors.black,
          digitSize: 20,
          showSeconds: false,
        ),
      ));

      // 10:30 -> four digits and one separator; seconds are gone.
      expect(find.text(':'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('FlipCountdown can hide seconds', (tester) async {
      await tester.pumpWidget(_wrap(
        const FlipCountdown(
          duration: Duration(hours: 2),
          showSeconds: false,
        ),
      ));

      // hours + minutes only -> a single separator.
      expect(find.text(':'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });

  // Reported as issue #1: changing the value used to require a Key, and then
  // the digits swapped without animating.
  group('value changes animate (issue #1)', () {
    testWidgets('a changed value flips instead of swapping', (tester) async {
      await tester.pumpWidget(_wrap(const FlipDigit(value: 1)));
      expect(find.text('1'), findsWidgets);

      // No key change: the element is reused and the panel animates.
      await tester.pumpWidget(_wrap(const FlipDigit(value: 2)));
      await tester.pump(const Duration(milliseconds: 150));

      // Mid-flip both faces are on screen; a plain swap would show only one.
      expect(find.text('1'), findsWidgets);
      expect(find.text('2'), findsWidgets);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a new Key rebuilds state, so the change is instant',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const FlipDigit(key: ValueKey('a'), value: 1)));
      expect(find.text('1'), findsWidgets);

      // Documents the limitation behind the issue: a different Key discards the
      // old state, so there is no previous value left to animate from.
      await tester.pumpWidget(
          _wrap(const FlipDigit(key: ValueKey('b'), value: 2)));
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('1'), findsNothing);
      expect(find.text('2'), findsWidgets);

      await tester.pumpWidget(const SizedBox());
    });
  });

  // A captioned segment is taller than the separator, so a naive centre
  // alignment lifted the colon away from the digits.
  group('separator alignment with labels', () {
    Future<void> expectColonLevelWithDigits(
      WidgetTester tester,
      FlipLabelPosition position,
    ) async {
      await tester.pumpWidget(_wrap(
        FlipCountdown(
          duration: const Duration(minutes: 12, seconds: 34),
          showLabels: true,
          labelPosition: position,
          style: const FlipDigitStyle.dark(fontSize: 20, width: 30, height: 44),
        ),
      ));

      final colon = tester.getRect(find.text(':').first);
      // '1' from the minutes segment.
      final digit = tester.getRect(find.text('1').first);

      expect(
        colon.center.dy,
        moreOrLessEquals(digit.center.dy, epsilon: 1.5),
        reason: 'the colon must sit level with the digits ($position)',
      );

      await tester.pumpWidget(const SizedBox());
    }

    testWidgets('labels below', (tester) async {
      await expectColonLevelWithDigits(tester, FlipLabelPosition.below);
    });

    testWidgets('labels above', (tester) async {
      await expectColonLevelWithDigits(tester, FlipLabelPosition.above);
    });
  });

  group('separator matches the digits', () {
    testWidgets('inherits weight, size and family from the style',
        (tester) async {
      const style = FlipDigitStyle(
        fontSize: 26,
        textColor: Colors.white,
        textStyle: TextStyle(fontFamily: 'Courier', letterSpacing: 2),
      );

      await tester.pumpWidget(_wrap(
        const FlipCountdown(duration: Duration(minutes: 12), style: style),
      ));

      final colon = tester.widget<Text>(find.text(':').first).style!;
      final digit = tester.widget<Text>(find.text('1').first).style!;

      expect(colon.fontWeight, digit.fontWeight);
      expect(colon.fontSize, digit.fontSize);
      expect(colon.fontFamily, digit.fontFamily);
      expect(colon.letterSpacing, digit.letterSpacing);
      expect(colon.color, digit.color);

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('digit vertical centring', () {
    // The glyph must sit centred in its panel: a default line box carries the
    // font's unused descent, which left more space above the digit than below.
    testWidgets('glyph is centred within the digit box', (tester) async {
      const style = FlipDigitStyle.dark(fontSize: 30, width: 50, height: 70);

      await tester.pumpWidget(_wrap(
        const FlipDigit(value: 8, style: style),
      ));

      final resolved = style.resolveTextStyle();
      expect(resolved.height, 1.0);
      expect(resolved.leadingDistribution, TextLeadingDistribution.even);

      final box = tester.getRect(find.byType(Container).first);
      final glyph = tester.getRect(find.text('8').first);

      final above = glyph.top - box.top;
      final below = box.bottom - glyph.bottom;
      expect(
        above,
        moreOrLessEquals(below, epsilon: 1.0),
        reason: 'space above and below the digit should match',
      );

      await tester.pumpWidget(const SizedBox());
    });
  });
}
