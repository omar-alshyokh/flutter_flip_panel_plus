# Flip Panel Plus

3D flip-panel widgets for Flutter: a countdown timer, a flip clock, and flipping
digits you can drive from any value.

<img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_countdown_controller.gif" width="420" alt="FlipCountdown" />

<p>
   <img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_clock.gif" width="200" height="450" />
   <img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_countdown.gif" width="200" height="450" />
</p>
<p>
   <img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_image.gif" width="200" height="450" />
   <img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/reverse_countdown.gif" width="200" height="450" />
</p>

## Why this package

A countdown is easy to get wrong. Most implementations subtract a second on
every tick, which quietly drifts when a frame is slow, and jumps to the wrong
value after the app has been in the background.

`FlipCountdown` derives the time left from how much time has actually passed,
and reads two clocks to do it (a monotonic one and the wall clock), taking
whichever has advanced further:

* **Late or dropped ticks** cannot cause drift; the value is recomputed, not
  decremented.
* **Backgrounding or device sleep** is handled: the wall clock catches the
  countdown back up.
* **Moving the device clock backwards** cannot rewind the countdown.
* **Server-driven deadlines** are supported directly: pass `referenceTime` and
  the device's own clock is never used to decide how long is left.

## Install

```yaml
dependencies:
  flip_panel_plus: ^2.0.0
```

```dart
import 'package:flip_panel_plus/flip_panel_plus.dart';
```

## Countdown

Count down to a moment:

```dart
FlipCountdown(
  targetDate: saleEndsAt,
  referenceTime: serverNow, // optional; keeps the device clock out of it
  onDone: () => setState(() => _finished = true),
)
```

Or for a fixed length:

```dart
FlipCountdown(
  duration: const Duration(hours: 1, minutes: 30),
  showLabels: true,
  onTick: (remaining) => debugPrint('$remaining'),
)
```

Segments are chosen automatically. Days only appear when the countdown is a day
or more, hours only when it is an hour or more. Override with `showDays`,
`showHours`, `showMinutes` and `showSeconds`.

![flip_countdown_controller](https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_countdown_controller.gif)

### Controlling it

Pass a `FlipCountdownController` when you need to drive the countdown from
elsewhere. A controller you create is yours to dispose.

```dart
final controller = FlipCountdownController(
  duration: const Duration(minutes: 10),
  autoStart: false,
);

FlipCountdown(controller: controller);

controller.start();
controller.pause();
controller.resume();
controller.addTime(const Duration(minutes: 5));
controller.reset(autoStart: true);

controller.remaining; // Duration
controller.progress;  // 0.0 -> 1.0
controller.status;    // idle | running | paused | completed
```

## Styling

Appearance lives in one object, [`FlipDigitStyle`], so a look can be defined
once and reused across every widget in the package.

<img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_styles.gif" width="300" alt="Styles" />

```dart
FlipCountdown(
  duration: d,
  style: FlipDigitStyle.card(seed: Colors.indigo),
)
```

Four presets to start from, each adjustable with `copyWith`:

| Preset | Look |
| --- | --- |
| `FlipDigitStyle.dark()` | the classic split-flap board |
| `FlipDigitStyle.light()` | inverted, with a hairline border |
| `FlipDigitStyle.card()` | tinted and raised, with a shadow |
| `FlipDigitStyle.minimal()` | no box at all, for overlaying artwork |

Gradients, borders and shadows are supported directly:

```dart
const FlipDigitStyle(
  fontSize: 26,
  borderRadius: BorderRadius.all(Radius.circular(10)),
  gradient: LinearGradient(colors: [Color(0xFFFF7A18), Color(0xFFE1231C)]),
)
```

### Removing the split line

A flip panel is drawn as two halves, and the gap between them is what gives a
split-flap its seam. Set `panelSpacing: 0` for a seamless digit:

```dart
FlipCountdown(duration: d, panelSpacing: 0)
```

### Labels, separators and segments

```dart
FlipCountdown(
  duration: d,
  showLabels: true,
  labelPosition: FlipLabelPosition.above,   // or below
  labels: const FlipCountdownLabels.short(), // D / H / M / S
  separator: const SizedBox(width: 10),      // or SizedBox.shrink() to remove
  showSeconds: false,                        // hide any segment
  curve: Curves.easeOutBack,                 // easing on the fold
)
```

### More looks, by composition

`FlipCountdown` is an ordinary widget, so looks that are not a digit style come
from wrapping it. Two common ones:

<img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_recipes.gif" width="420" alt="Ruled and compact strip" />

**Ruled**, with rules above and below and no boxes:

```dart
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(height: 1.5, color: Colors.white24),
    const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: FlipCountdown(
        duration: d,
        panelSpacing: 0,
        separator: SizedBox(width: 8),
        style: FlipDigitStyle.minimal(fontSize: 30),
      ),
    ),
    Container(height: 1.5, color: Colors.white24),
  ],
)
```

**Compact strip**, with an icon, a caption and the time on one line:

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  decoration: BoxDecoration(
    color: const Color(0xFF1F6F4A),
    borderRadius: BorderRadius.circular(10),
  ),
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.timer_outlined, color: Colors.white, size: 18),
      SizedBox(width: 6),
      Text('ENDS IN', style: TextStyle(color: Colors.white, fontSize: 12)),
      SizedBox(width: 12),
      FlipCountdown(
        duration: d,
        panelSpacing: 0,
        style: FlipDigitStyle.minimal(fontSize: 18, width: 15, height: 26),
      ),
    ],
  ),
)
```

> **Tip on flip speed.** `flipDuration` defaults to 450ms. Against a one-second
> tick that means the digit is mid-fold for nearly half of every second, which
> is fine behind a solid panel but reads as a broken glyph on the box-less
> styles above. Shorten it (240 to 300ms) whenever the digits have no panel to
> fold against.

### Languages and RTL

Labels are ordinary strings, so pass whatever language you need:

```dart
FlipCountdown(
  duration: d,
  showLabels: true,
  labels: const FlipCountdownLabels(
    days: 'أيام',
    hours: 'ساعات',
    minutes: 'دقائق',
    seconds: 'ثوانٍ',
  ),
)
```

Digits can use another numeral system through `digitFormatter`:

```dart
style: const FlipDigitStyle.dark()
    .copyWith(digitFormatter: FlipDigitStyle.easternArabicNumerals), // ١٢:٣٤
```

**In an RTL app the countdown still reads left to right.** A clock is not
mirrored in Arabic or Hebrew: the hours stay on the left, and `12` stays `12`
rather than becoming `21`. The package pins the layout direction for you, so
dropping it inside an RTL `Directionality` needs no extra work. If you do want
the segments mirrored, ask for it explicitly:

```dart
FlipCountdown(duration: d, textDirection: TextDirection.rtl)
```

### When it finishes

```dart
FlipCountdown(
  duration: d,
  completedBuilder: (context) => const Text('EXPIRED'),
)
```

### Complete control

`digitBuilder` replaces the digit rendering entirely:

```dart
FlipCountdown(
  duration: d,
  digitBuilder: (context, digit) => MyOwnDigit(digit),
)
```

And [`FlipCountdownBuilder`] gives you the timing engine with no UI at all, so
the countdown can drive anything: a progress ring, a sentence, a chart.

```dart
FlipCountdownBuilder(
  targetDate: saleEndsAt,
  builder: (context, remaining, status) =>
      Text('${remaining.inMinutes} min left'),
)
```

## Flip digits

`FlipDigit` and `FlipNumber` flip whenever their value changes, with no stream to
set up. Only the digits that actually change will flip.

```dart
FlipDigit(value: 7)

FlipNumber(value: score, minDigits: 4) // 0042
```

## Flip clock

```dart
FlipClockPlus.simple(
  startTime: DateTime.now(),
  digitColor: Colors.white,
  backgroundColor: Colors.black,
  digitSize: 30.0,
  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
)
```

A countdown in the same style:

```dart
FlipClockPlus.countdown(
  duration: const Duration(hours: 1),
  digitColor: Colors.white,
  backgroundColor: Colors.black,
  digitSize: 48.0,
  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
  onDone: () => debugPrint('done'),
)
```

With days and captions:

```dart
FlipClockPlus.reverseCountdown(
  duration: const Duration(days: 10),
  digitColor: Colors.white,
  backgroundColor: Colors.black,
  digitSize: 30.0,
  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
  onDone: () => debugPrint('done'),
)
```

## Flipping any widget

`FlipPanelPlus` is the animation underneath, and works with any widget.

From a list:

```dart
final digits = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

FlipPanelPlus.builder(
  itemBuilder: (context, index) => Container(
    color: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 6.0),
    child: Text(
      '${digits[index]}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 50.0,
        color: Colors.white,
      ),
    ),
  ),
  itemsCount: digits.length,
  period: const Duration(milliseconds: 1000),
  loop: -1, // forever
)
```

From a stream:

```dart
FlipPanelPlus<int>.stream(
  itemStream: myStream,
  itemBuilder: (context, value) => Text('$value'),
  initValue: 0,
)
```

`period` must be at least twice `duration`, otherwise the animation has no time
to settle between flips.

## Testing

Time is read through [`package:clock`](https://pub.dev/packages/clock), so
countdowns can be driven deterministically in tests with `withClock`, and they
advance normally under `testWidgets` and `fakeAsync`.

## Credits

Based on [flip_panel](https://pub.dev/packages/flip_panel), which is no longer
maintained.

## License

MIT. See [LICENSE](LICENSE).
