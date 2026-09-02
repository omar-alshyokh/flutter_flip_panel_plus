import 'package:flutter/widgets.dart';

/// Builds the visual for a single digit (0-9) of a clock or countdown.
typedef DigitBuilder = Widget Function(BuildContext context, int digit);

/// Builds a widget for a given index, used by [FlipPanelPlus.builder].
typedef IndexedItemBuilder = Widget Function(BuildContext context, int index);

/// Builds a widget for a value emitted by a [Stream], used by
/// [FlipPanelPlus.stream].
typedef StreamItemBuilder<T> = Widget Function(BuildContext context, T value);
