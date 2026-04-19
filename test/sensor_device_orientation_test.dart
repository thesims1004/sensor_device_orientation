import 'package:flutter_test/flutter_test.dart';

import 'package:sensor_device_orientation/sensor_device_orientation.dart';

void main() {
  group('SensorDeviceOrientation', () {
    test('quarterTurns matches expected RotatedBox semantics', () {
      expect(SensorDeviceOrientation.portraitUp.quarterTurns, 0);
      expect(SensorDeviceOrientation.landscapeLeft.quarterTurns, 1);
      expect(SensorDeviceOrientation.portraitDown.quarterTurns, 2);
      expect(SensorDeviceOrientation.landscapeRight.quarterTurns, 3);
      expect(SensorDeviceOrientation.flat.quarterTurns, 0);
    });

    test('isLandscape / isPortrait classification', () {
      expect(SensorDeviceOrientation.portraitUp.isPortrait, isTrue);
      expect(SensorDeviceOrientation.portraitUp.isLandscape, isFalse);

      expect(SensorDeviceOrientation.portraitDown.isPortrait, isTrue);
      expect(SensorDeviceOrientation.portraitDown.isLandscape, isFalse);

      expect(SensorDeviceOrientation.landscapeLeft.isLandscape, isTrue);
      expect(SensorDeviceOrientation.landscapeLeft.isPortrait, isFalse);

      expect(SensorDeviceOrientation.landscapeRight.isLandscape, isTrue);
      expect(SensorDeviceOrientation.landscapeRight.isPortrait, isFalse);

      expect(SensorDeviceOrientation.flat.isPortrait, isFalse);
      expect(SensorDeviceOrientation.flat.isLandscape, isFalse);
    });
  });

  group('SensorDeviceOrientationDetector', () {
    test('singleton instance is consistent', () {
      final a = SensorDeviceOrientationDetector.instance;
      final b = SensorDeviceOrientationDetector.instance;
      expect(identical(a, b), isTrue);
    });

    test('default value is portraitUp before first sample', () {
      SensorDeviceOrientationDetector.instance.debugReset();
      expect(SensorDeviceOrientationDetector.instance.value,
          SensorDeviceOrientation.portraitUp);
    });
  });
}
