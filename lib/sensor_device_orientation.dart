/// Sensor-based physical device orientation detection.
///
/// Detects the actual physical orientation of a mobile device using
/// accelerometer data, even when the screen rotation is locked.
///
/// ## Quick start
///
/// ```dart
/// import 'package:sensor_device_orientation/sensor_device_orientation.dart';
///
/// // 1. As a widget
/// SensorDeviceOrientationBuilder(
///   builder: (context, orientation) => RotatedBox(
///     quarterTurns: orientation.quarterTurns,
///     child: const Icon(Icons.flash_on),
///   ),
/// );
///
/// // 2. As a stream
/// SensorDeviceOrientationDetector.instance.stream.listen((o) {
///   print('Device is now $o');
/// });
///
/// // 3. Drop-in RotatedBox replacement
/// SensorRotatedBox(
///   child: const Text('I rotate with the device'),
/// );
/// ```
library;

export 'src/orientation.dart';
export 'src/detector.dart' show SensorDeviceOrientationDetector;
export 'src/widgets.dart';
