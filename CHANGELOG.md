## 2.0.0

Modernised for current Flutter, with a new countdown API and a rewritten timing
engine. The existing widgets keep their constructors, so most code upgrades by
bumping the version.

### Added
* `FlipDigitStyle`, the look of a digit in one reusable object, with gradient,
  border, shadow and text-style support, a `copyWith`, and four presets:
  `dark`, `light`, `card` and `minimal`.
* `FlipCountdownBuilder`, the timing engine with no opinion about appearance,
  so any UI can be driven by it.
* `completedBuilder` on `FlipCountdown`, to replace the digits once it finishes.
* `labelPosition` (above or below), `labelSpacing`, and
  `FlipCountdownLabels.short()`.
* `curve`, for easing the fold.
* `digitFormatter` on `FlipDigitStyle`, plus
  `FlipDigitStyle.easternArabicNumerals`, for other numeral systems.
* `textDirection` on `FlipCountdown`, for mirroring the segments on request.
* Segment visibility on `FlipClockPlus`: `showHours`, `showMinutes` and
  `showSeconds` can now be set directly. This was asked for in issue #1.
* `FlipCountdown`, a countdown widget that can target a `DateTime` or a
  `Duration`, choose its segments automatically, and report `onTick`/`onDone`.
* `FlipCountdownController`, with start, pause, resume, reset and `addTime`, plus
  `remaining`, `progress` and `status`.
* `FlipDigit` and `FlipNumber`, value-driven flipping digits that can be used
  on their own, with no stream to wire up.
* `referenceTime`, so a countdown can be measured against a server clock instead
  of the device clock.
* `defaultDigitBuilder`, exposing the built-in digit styling for reuse.

### Fixed
* **A parent rebuild no longer restarts a running clock or countdown.** The
  timing stream used to be recreated on every `build`, so any rebuild silently
  started the countdown again and leaked the previous timer.
* Countdown timing is now derived from elapsed time rather than by subtracting a
  fixed amount per tick, so a late or dropped tick cannot cause drift.
* The countdown keeps correct time while the app is backgrounded or the device
  is asleep, and cannot be rewound by moving the device clock backwards.
* `FlipClockPlus` no longer mutates its own fields; it is a `StatefulWidget` and
  the `must_be_immutable` suppression is gone.
* `_FlipPanelPlusState` is now generic over its widget type, removing the
  internal casts and the mismatched builder signatures.
* Timers and stream subscriptions are cancelled reliably on dispose.
* The days segment counts past 99 instead of clamping to `99`.
* Digits are now vertically centred in their panel. A text line box carries the
  font's ascent and descent, and digits have no descender, so centring the line
  box left visibly more space on one side of the glyph than the other.
* The separator now inherits the digits' weight, size and font, instead of
  rendering in a lighter, mismatched style.
* The separator stays level with the digits when captions are shown; a captioned
  segment is taller, and centring the row used to float the colon away from
  the digits.
* The countdown no longer mirrors itself inside an RTL app. A clock reads left
  to right in every locale, but an ambient RTL `Directionality` reversed both
  the segment order (seconds where the hours belong) and the digits within each
  number, so `12` was displayed as `21`.
* Countdown constructors no longer build a `DateTime` from month `0`, day `0`.

### Changed
* **Breaking:** minimum SDK is now Dart 3.4 / Flutter 3.10.
* **Breaking:** typedefs are typed. `DigitBuilder` is
  `Widget Function(BuildContext, int)` and `StreamItemBuilder<T>` is
  `Widget Function(BuildContext, T)`; both previously took `dynamic`. Existing
  lambdas that rely on inference keep working.
* The library is split into `lib/src/`, exported from `flip_panel_plus.dart`.
* Added a dependency on `package:clock`, which lets the countdown be tested and
  driven with `withClock`.
* Generated platform folders are no longer part of the package.
* `flutter_lints` upgraded to `^5.0.0`; the package analyses with no issues.
* Added a test suite covering the controller, the widgets and the rebuild fix.

## 1.0.0+3
* Update: pubspec.yaml description
* Format: Flutter format

## 1.0.0+2
* Update: pubspec.yaml description
* Delete: unnecessary code

## 1.0.0+1
* Update: the example

## 1.0.0
* migrate to null safety.
* Update: environment sdk and flutter
* Fix: fix some issues example app name
* Add: new properties [centerGapSpace , daysLabelStr, hoursLabelStr, minutesLabelStr, secondsLabelStr] 
* Update: LICENSE
* Update: README.md file
