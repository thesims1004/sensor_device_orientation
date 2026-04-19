import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'orientation.dart';

/// Singleton service that detects physical device orientation from
/// accelerometer data.
///
/// Subscribes to [accelerometerEventStream] lazily on first listen and
/// keeps a single subscription alive regardless of how many widgets
/// observe the orientation.
///
/// ### Why a singleton?
///
/// Each `accelerometerEventStream()` subscription on Android registers
/// a sensor listener with `SensorManager`. Multiple subscriptions waste
/// battery and can produce inconsistent readings due to filter state
/// being separate per subscription. A single shared service avoids this.
///
/// ### Filtering
///
/// Raw accelerometer data is noisy. This detector applies:
/// 1. **Low-pass filter** (exponential moving average) to smooth jitter.
/// 2. **Hysteresis** around the diagonal boundaries between orientations
///    so that the reported orientation does not flicker when the device
///    is held near a 45° boundary.
class SensorDeviceOrientationDetector {
  SensorDeviceOrientationDetector._() {
    _controller = StreamController<SensorDeviceOrientation>.broadcast(
      onListen: _start,
      onCancel: _stopIfIdle,
    );
  }

  /// Global shared instance.
  static final SensorDeviceOrientationDetector instance =
      SensorDeviceOrientationDetector._();

  // --- Tunable parameters --------------------------------------------------

  /// Smoothing factor for the low-pass filter (0..1).
  /// Higher = more responsive, lower = smoother.
  static const double _smoothing = 0.2;

  /// Magnitude threshold below which the device is considered [flat].
  /// Accelerometer values are in m/s²; gravity is ~9.8.
  /// When the device is lying flat, the x/y components are near zero.
  static const double _flatThreshold = 4.0;

  /// Hysteresis margin to prevent flickering near the 45° boundary.
  /// The new orientation must dominate the previous one by this ratio
  /// before switching.
  static const double _hysteresis = 1.2;

  // --- State ---------------------------------------------------------------

  late final StreamController<SensorDeviceOrientation> _controller;

  StreamSubscription<AccelerometerEvent>? _sub;
  double _filteredX = 0;
  double _filteredY = -9.8; // assume portraitUp at startup
  bool _primed = false;

  SensorDeviceOrientation _current = SensorDeviceOrientation.portraitUp;

  /// Current best-guess orientation. Updates as soon as the sensor
  /// produces a stable reading; defaults to [SensorDeviceOrientation.portraitUp]
  /// before the first sample arrives.
  SensorDeviceOrientation get value => _current;

  /// Broadcast stream of orientation changes. Emits only when the
  /// orientation actually changes (not on every sensor sample).
  Stream<SensorDeviceOrientation> get stream => _controller.stream;

  // --- Lifecycle -----------------------------------------------------------

  void _start() {
    if (_sub != null) return;
    _sub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100), // ~10 Hz
    ).listen(
      _onSample,
      onError: (Object e, StackTrace s) {
        debugPrint('[SensorDeviceOrientation] sensor error: $e');
      },
      cancelOnError: false,
    );
  }

  void _stopIfIdle() {
    if (_controller.hasListener) return;
    _sub?.cancel();
    _sub = null;
    _primed = false;
  }

  void _onSample(AccelerometerEvent event) {
    // Low-pass filter (exponential moving average)
    if (!_primed) {
      _filteredX = event.x;
      _filteredY = event.y;
      _primed = true;
    } else {
      _filteredX = _filteredX * (1 - _smoothing) + event.x * _smoothing;
      _filteredY = _filteredY * (1 - _smoothing) + event.y * _smoothing;
    }

    final next = _classify(_filteredX, _filteredY, _current);
    if (next != _current) {
      _current = next;
      _controller.add(next);
    }
  }

  /// Classify orientation from filtered accelerometer x/y components.
  ///
  /// Coordinate system (Flutter / sensors_plus, device-local):
  /// - **+x**: right edge of the device when held in portraitUp
  /// - **+y**: top edge of the device when held in portraitUp
  /// - **+z**: out of the screen
  ///
  /// Gravity is roughly (0, -9.8, 0) in portraitUp (gravity pulls
  /// the bottom of the device down, so the y-component reads negative).
  SensorDeviceOrientation _classify(
    double x,
    double y,
    SensorDeviceOrientation previous,
  ) {
    final ax = x.abs();
    final ay = y.abs();

    // Device is lying mostly flat — keep previous orientation.
    if (ax < _flatThreshold && ay < _flatThreshold) {
      return previous == SensorDeviceOrientation.flat ? previous : previous;
    }

    // Determine candidate from dominant axis.
    final SensorDeviceOrientation candidate;
    if (ay > ax) {
      candidate = y < 0
          ? SensorDeviceOrientation.portraitUp
          : SensorDeviceOrientation.portraitDown;
    } else {
      candidate = x > 0
          ? SensorDeviceOrientation.landscapeRight
          : SensorDeviceOrientation.landscapeLeft;
    }

    if (candidate == previous) return previous;

    // Hysteresis: require the dominant axis to clearly dominate before
    // switching, to avoid flickering near the 45° boundary.
    final dominant = ay > ax ? ay : ax;
    final other = ay > ax ? ax : ay;
    if (other == 0 || dominant / other >= _hysteresis) {
      return candidate;
    }
    return previous;
  }

  /// Visible for testing — overrides the shared instance for unit tests.
  @visibleForTesting
  void debugReset() {
    _sub?.cancel();
    _sub = null;
    _primed = false;
    _filteredX = 0;
    _filteredY = -9.8;
    _current = SensorDeviceOrientation.portraitUp;
  }
}
