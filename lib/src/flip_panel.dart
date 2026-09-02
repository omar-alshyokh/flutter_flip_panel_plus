import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'flip_direction.dart';
import 'typedefs.dart';

/// A widget that shows a 3D flip animation between two panels, like the split
/// flap display on a departure board.
///
/// Content is produced either from an [IndexedItemBuilder] (see
/// [FlipPanelPlus.builder]) or from a [Stream] via a [StreamItemBuilder] (see
/// [FlipPanelPlus.stream]).
///
/// Every panel must render at the same size, otherwise the two halves will not
/// line up during the fold.
class FlipPanelPlus<T> extends StatefulWidget {
  /// Builds panel content by index. Set for [FlipPanelPlus.builder].
  final IndexedItemBuilder? indexedItemBuilder;

  /// Builds panel content from a stream value. Set for [FlipPanelPlus.stream].
  final StreamItemBuilder<T>? streamItemBuilder;

  /// The source of values in stream mode.
  final Stream<T>? itemStream;

  /// Total number of items in builder mode.
  final int? itemsCount;

  /// How often the panel advances in builder mode.
  final Duration? period;

  /// How long a single flip takes.
  final Duration? duration;

  /// How many times to loop in builder mode. `-1` loops forever.
  final int? loop;

  /// The index the panel starts from in builder mode.
  final int? startIndex;

  /// The value shown before the stream emits anything.
  final T? initValue;

  /// Vertical gap between the upper and lower halves.
  final double? spacing;

  /// Whether the panel folds [FlipDirection.up] or [FlipDirection.down].
  final FlipDirection? direction;

  /// Easing applied to the fold. Defaults to [Curves.linear], which matches a
  /// mechanical split-flap board.
  final Curve? curve;

  const FlipPanelPlus({
    super.key,
    this.indexedItemBuilder,
    this.streamItemBuilder,
    this.itemStream,
    this.itemsCount,
    this.period,
    this.duration,
    this.loop,
    this.startIndex,
    this.initValue,
    this.spacing,
    this.direction,
    this.curve,
  });

  /// Creates a flip panel that advances through [itemsCount] items.
  ///
  /// [itemBuilder] is called once every [period]. The animation runs [loop]
  /// times before stopping; pass `-1` to loop forever.
  ///
  /// [period] must be at least twice [duration], otherwise the animation has no
  /// time to settle between flips and looks jerky.
  FlipPanelPlus.builder({
    super.key,
    required IndexedItemBuilder itemBuilder,
    required this.itemsCount,
    required this.period,
    this.duration = const Duration(milliseconds: 500),
    this.loop = 1,
    this.startIndex = 0,
    this.spacing = 0.5,
    this.direction = FlipDirection.down,
    this.curve,
  })  : assert(itemsCount != null && itemsCount > 0,
            'itemsCount must be greater than zero'),
        assert(startIndex! < itemsCount!, 'startIndex must be within itemsCount'),
        assert(
            period == null ||
                period.inMilliseconds >= 2 * duration!.inMilliseconds,
            'period must be at least twice duration'),
        indexedItemBuilder = itemBuilder,
        streamItemBuilder = null,
        itemStream = null,
        initValue = null;

  /// Creates a flip panel driven by [itemStream].
  ///
  /// [itemBuilder] is called whenever the stream emits a value that differs
  /// from the current one.
  const FlipPanelPlus.stream({
    super.key,
    required this.itemStream,
    required StreamItemBuilder<T> itemBuilder,
    this.initValue,
    this.duration = const Duration(milliseconds: 500),
    this.spacing = 0.5,
    this.direction = FlipDirection.down,
    this.curve,
  })  : indexedItemBuilder = null,
        streamItemBuilder = itemBuilder,
        itemsCount = 0,
        period = null,
        loop = 0,
        startIndex = 0;

  @override
  State<FlipPanelPlus<T>> createState() => _FlipPanelPlusState<T>();
}

class _FlipPanelPlusState<T> extends State<FlipPanelPlus<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  late int _currentIndex;
  late bool _isReversePhase;
  late bool _isStreamMode;
  late bool _running;
  late int _loop;

  static const double _perspective = 0.003;

  // A very small angle is used instead of zero: an exact zero produces a
  // degenerate perspective transform.
  static const double _zeroAngle = 0.0001;

  T? _currentValue;
  T? _nextValue;

  Timer? _timer;
  StreamSubscription<T>? _subscription;

  Widget? _child1, _child2;
  Widget? _upperChild1, _upperChild2;
  Widget? _lowerChild1, _lowerChild2;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex ?? 0;
    _isStreamMode = widget.itemStream != null;
    _isReversePhase = false;
    _running = false;
    _loop = 0;

    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 500),
      vsync: this,
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _isReversePhase = true;
          _controller.reverse();
        }
        if (status == AnimationStatus.dismissed) {
          _currentValue = _nextValue;
          _running = false;
        }
      })
      ..addListener(() {
        if (!mounted) return;
        setState(() => _running = true);
      });

    final curve = widget.curve;
    _animation = Tween<double>(begin: _zeroAngle, end: math.pi / 2).animate(
      curve == null
          ? _controller
          : CurvedAnimation(parent: _controller, curve: curve),
    );

    _startBuilderMode();
    _startStreamMode();
  }

  void _startBuilderMode() {
    final period = widget.period;
    final itemsCount = widget.itemsCount ?? 0;
    if (period == null || itemsCount <= 0) return;

    _timer = Timer.periodic(period, (_) {
      final loopTarget = widget.loop ?? 0;
      if (loopTarget < 0 || _loop < loopTarget) {
        if (_currentIndex + 1 == itemsCount - 2) _loop++;
        _currentIndex = (_currentIndex + 1) % itemsCount;
        _child1 = null;
        _isReversePhase = false;
        _controller.forward();
      } else {
        _timer?.cancel();
        _currentIndex = (_currentIndex + 1) % itemsCount;
        if (mounted) setState(() => _running = false);
      }
    });
  }

  void _startStreamMode() {
    if (!_isStreamMode) {
      final loopTarget = widget.loop ?? 0;
      if (widget.period == null && (loopTarget < 0 || _loop < loopTarget)) {
        _controller.forward();
      }
      return;
    }

    _currentValue = widget.initValue;
    _subscription = widget.itemStream!.distinct().listen((value) {
      if (!mounted) return;
      if (_currentValue == null) {
        setState(() => _currentValue = value);
      } else if (value != _currentValue) {
        _nextValue = value;
        _child1 = null;
        _isReversePhase = false;
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nothing to show until the stream produces its first value.
    if (_isStreamMode && _currentValue == null) {
      return const SizedBox.shrink();
    }
    _buildChildWidgetsIfNeed(context);
    return _buildPanel();
  }

  Widget _buildContent(T? value, int index) {
    if (_isStreamMode) {
      return widget.streamItemBuilder!(context, value as T);
    }
    final count = widget.itemsCount ?? 1;
    return widget.indexedItemBuilder!(context, index % (count == 0 ? 1 : count));
  }

  void _buildChildWidgetsIfNeed(BuildContext context) {
    Widget makeUpperClip(Widget child) => ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 0.5,
            child: child,
          ),
        );

    Widget makeLowerClip(Widget child) => ClipRect(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 0.5,
            child: child,
          ),
        );

    if (_running) {
      if (_child1 == null) {
        _child1 = _child2 ?? _buildContent(_currentValue, _currentIndex);
        _child2 = null;
        _upperChild1 = _upperChild2 ?? makeUpperClip(_child1!);
        _lowerChild1 = _lowerChild2 ?? makeLowerClip(_child1!);
      }
      if (_child2 == null) {
        _child2 = _buildContent(_nextValue, _currentIndex + 1);
        _upperChild2 = makeUpperClip(_child2!);
        _lowerChild2 = makeLowerClip(_child2!);
      }
    } else {
      _child1 = _child2 ?? _buildContent(_currentValue, _currentIndex);
      _upperChild1 = _upperChild2 ?? makeUpperClip(_child1!);
      _lowerChild1 = _lowerChild2 ?? makeLowerClip(_child1!);
    }
  }

  Widget _buildUpperFlipPanel() => widget.direction == FlipDirection.up
      ? Stack(
          children: [
            Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(_zeroAngle),
              child: _upperChild1,
            ),
            Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(_isReversePhase ? _animation.value : math.pi / 2),
              child: _upperChild2,
            ),
          ],
        )
      : Stack(
          children: [
            Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(_zeroAngle),
              child: _upperChild2,
            ),
            Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(_isReversePhase ? math.pi / 2 : _animation.value),
              child: _upperChild1,
            ),
          ],
        );

  Widget _buildLowerFlipPanel() => widget.direction == FlipDirection.up
      ? Stack(
          children: [
            Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(_zeroAngle),
              child: _lowerChild2,
            ),
            Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(_isReversePhase ? math.pi / 2 : -_animation.value),
              child: _lowerChild1,
            ),
          ],
        )
      : Stack(
          children: [
            Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(_zeroAngle),
              child: _lowerChild1,
            ),
            Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(_isReversePhase ? -_animation.value : math.pi / 2),
              child: _lowerChild2,
            ),
          ],
        );

  Widget _buildPanel() {
    final gap = widget.spacing ?? 0.5;
    if (_running) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUpperFlipPanel(),
          Padding(padding: EdgeInsets.only(top: gap)),
          _buildLowerFlipPanel(),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..rotateX(_zeroAngle),
          child: _upperChild1,
        ),
        Padding(padding: EdgeInsets.only(top: gap)),
        Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..rotateX(_zeroAngle),
          child: _lowerChild1,
        ),
      ],
    );
  }
}
