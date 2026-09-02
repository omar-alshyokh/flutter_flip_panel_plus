/// 3D flip-panel widgets for Flutter.
///
/// * [FlipCountdown] — a countdown built from flipping digits, with an optional
///   [FlipCountdownController] for pause, resume and reset.
/// * [FlipCountdownBuilder] — the same timing engine with no opinion about how
///   it looks; build any countdown UI from it.
/// * [FlipClockPlus] — a flip clock, or a simple flip countdown.
/// * [FlipDigit] and [FlipNumber] — value-driven flipping digits.
/// * [FlipDigitStyle] — the look of a digit, with ready-made presets.
/// * [FlipPanelPlus] — the underlying flip animation for arbitrary widgets.
library;

export 'src/countdown/flip_countdown.dart';
export 'src/countdown/flip_countdown_builder.dart';
export 'src/countdown/flip_countdown_controller.dart';
export 'src/flip_clock.dart';
export 'src/flip_digit.dart';
export 'src/flip_digit_style.dart';
export 'src/flip_direction.dart';
export 'src/flip_panel.dart';
export 'src/typedefs.dart';
