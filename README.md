# sensor_device_orientation

Sensor-based **physical** device orientation detection for Flutter.
Works **even when screen rotation is locked**.

Built on `sensors_plus` accelerometer data with low-pass filtering and
hysteresis to prevent flickering. Designed for camera apps and other
UIs that need to rotate individual elements (icons, text, controls)
while keeping the screen layout fixed in portrait.

## Why?

| Approach | Works with rotation lock? | Stable? |
|---|---|---|
| `MediaQuery.of(context).orientation` | ❌ Always portrait | ✅ |
| `native_device_orientation` | ✅ | ⚠️ Crashes on some Android devices (Fragment NPE) |
| **`sensor_device_orientation`** | ✅ | ✅ Pure Dart on top of `sensors_plus` |

## Install

```yaml
dependencies:
  sensor_device_orientation: ^0.1.0
```

## Usage

### As a widget (recommended)

```dart
import 'package:sensor_device_orientation/sensor_device_orientation.dart';

SensorDeviceOrientationBuilder(
  builder: (context, orientation) {
    return RotatedBox(
      quarterTurns: orientation.quarterTurns,
      child: const Icon(Icons.flash_on),
    );
  },
);
```

### Drop-in `RotatedBox` replacement

```dart
SensorRotatedBox(
  child: const Text('I rotate with the device'),
);

// With smooth animation
SensorRotatedBox(
  animate: true,
  duration: const Duration(milliseconds: 300),
  child: const Icon(Icons.timer),
);
```

### As a stream

```dart
final sub = SensorDeviceOrientationDetector.instance.stream.listen((o) {
  print('Device is now $o');
});
// remember to cancel in dispose()
```

### Current value (one-shot)

```dart
final orientation = SensorDeviceOrientationDetector.instance.value;
```

## How it works

1. **Single shared subscription** to `accelerometerEventStream` (~10 Hz)
2. **Low-pass filter** (exponential moving average, α = 0.2) smooths jitter
3. **Hysteresis** (1.2× margin) at 45° boundaries prevents flickering
4. **Lazy lifecycle** — sensor stops when no listeners remain

## API

```dart
enum SensorDeviceOrientation { portraitUp, portraitDown, landscapeLeft, landscapeRight, flat }

extension on SensorDeviceOrientation {
  int get quarterTurns;     // 0..3 for RotatedBox
  bool get isLandscape;
  bool get isPortrait;
}

class SensorDeviceOrientationDetector {
  static final SensorDeviceOrientationDetector instance;
  SensorDeviceOrientation get value;
  Stream<SensorDeviceOrientation> get stream;
}

class SensorDeviceOrientationBuilder extends StatefulWidget {
  final Widget Function(BuildContext, SensorDeviceOrientation) builder;
}

class SensorRotatedBox extends StatelessWidget {
  final Widget child;
  final bool animate;
  final Duration duration;
}
```

## Example use case: camera app

```dart
// Screen locked to portrait, but UI elements rotate with the device
Stack(
  children: [
    const CameraPreview(),
    Positioned(
      top: 40, right: 16,
      child: SensorRotatedBox(
        animate: true,
        child: IconButton(
          icon: const Icon(Icons.flash_on),
          onPressed: _toggleFlash,
        ),
      ),
    ),
  ],
);
```

## License

MIT
