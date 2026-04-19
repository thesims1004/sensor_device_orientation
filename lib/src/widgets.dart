import 'package:flutter/widgets.dart';

import 'detector.dart';
import 'orientation.dart';

/// A widget that rebuilds when the physical device orientation changes.
///
/// Internally listens to [SensorDeviceOrientationDetector.instance.stream].
/// Multiple instances share the same underlying sensor subscription —
/// safe to use anywhere in the widget tree.
class SensorDeviceOrientationBuilder extends StatefulWidget {
  /// Builder called with the latest physical orientation.
  ///
  /// Called immediately on first build with the current cached value
  /// (defaults to [SensorDeviceOrientation.portraitUp] before the first
  /// sensor sample arrives).
  final Widget Function(BuildContext context, SensorDeviceOrientation orientation)
      builder;

  const SensorDeviceOrientationBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<SensorDeviceOrientationBuilder> createState() =>
      _SensorDeviceOrientationBuilderState();
}

class _SensorDeviceOrientationBuilderState
    extends State<SensorDeviceOrientationBuilder> {
  late SensorDeviceOrientation _orientation;

  @override
  void initState() {
    super.initState();
    _orientation = SensorDeviceOrientationDetector.instance.value;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorDeviceOrientation>(
      stream: SensorDeviceOrientationDetector.instance.stream,
      initialData: _orientation,
      builder: (context, snapshot) {
        final orientation =
            snapshot.data ?? SensorDeviceOrientation.portraitUp;
        return widget.builder(context, orientation);
      },
    );
  }
}

/// A drop-in replacement for [RotatedBox] that rotates its [child] to
/// match the physical device orientation, keeping content readable to
/// the user even when screen rotation is locked.
///
/// Equivalent to:
/// ```dart
/// SensorDeviceOrientationBuilder(
///   builder: (context, o) => RotatedBox(
///     quarterTurns: o.quarterTurns,
///     child: child,
///   ),
/// );
/// ```
class SensorRotatedBox extends StatelessWidget {
  final Widget child;

  /// If true, uses [AnimatedRotation] for a smooth transition between
  /// orientations instead of an instant snap.
  final bool animate;

  /// Animation duration when [animate] is true.
  final Duration duration;

  const SensorRotatedBox({
    super.key,
    required this.child,
    this.animate = false,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  Widget build(BuildContext context) {
    return SensorDeviceOrientationBuilder(
      builder: (context, orientation) {
        if (animate) {
          // AnimatedRotation works with arbitrary turns (full circle = 1.0)
          final turns = orientation.quarterTurns / 4.0;
          return AnimatedRotation(
            turns: turns,
            duration: duration,
            curve: Curves.easeOutCubic,
            child: child,
          );
        }
        return RotatedBox(
          quarterTurns: orientation.quarterTurns,
          child: child,
        );
      },
    );
  }
}
