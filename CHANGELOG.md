## 0.1.0

Initial release.

* `SensorDeviceOrientation` enum with `quarterTurns`, `isPortrait`, `isLandscape` extensions.
* `SensorDeviceOrientationDetector` — singleton service with shared accelerometer subscription, low-pass filter, and hysteresis.
* `SensorDeviceOrientationBuilder` — widget that rebuilds on orientation change.
* `SensorRotatedBox` — drop-in `RotatedBox` replacement with optional animation.
