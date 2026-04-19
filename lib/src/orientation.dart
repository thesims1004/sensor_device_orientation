/// Physical orientation of a mobile device, derived from accelerometer data.
///
/// Unlike [MediaQuery.of(context).orientation] which reflects the screen
/// orientation (and stays portrait when screen rotation is locked), this
/// enum represents the actual physical pose of the device.
enum SensorDeviceOrientation {
  /// Device is held upright in portrait mode (home button / bottom edge down).
  portraitUp,

  /// Device is held upside-down in portrait mode.
  portraitDown,

  /// Device is rotated 90° counter-clockwise (left edge down).
  ///
  /// Equivalent to tilting the **top of the device to the left**.
  landscapeLeft,

  /// Device is rotated 90° clockwise (right edge down).
  ///
  /// Equivalent to tilting the **top of the device to the right**.
  landscapeRight,

  /// Device is lying flat (face up or face down) — orientation
  /// cannot be determined reliably from accelerometer alone.
  flat,
}

extension SensorDeviceOrientationX on SensorDeviceOrientation {
  /// Number of clockwise quarter turns to apply via [RotatedBox] so that
  /// a child widget appears upright to a viewer holding the device in
  /// the corresponding orientation.
  ///
  /// - [portraitUp] / [flat] → 0
  /// - [landscapeLeft] → 1 (90° CW)
  /// - [portraitDown] → 2
  /// - [landscapeRight] → 3 (270° CW = 90° CCW)
  int get quarterTurns {
    switch (this) {
      case SensorDeviceOrientation.landscapeLeft:
        return 1;
      case SensorDeviceOrientation.portraitDown:
        return 2;
      case SensorDeviceOrientation.landscapeRight:
        return 3;
      case SensorDeviceOrientation.portraitUp:
      case SensorDeviceOrientation.flat:
        return 0;
    }
  }

  /// Whether this orientation represents a landscape pose.
  bool get isLandscape =>
      this == SensorDeviceOrientation.landscapeLeft ||
      this == SensorDeviceOrientation.landscapeRight;

  /// Whether this orientation represents a portrait pose.
  bool get isPortrait =>
      this == SensorDeviceOrientation.portraitUp ||
      this == SensorDeviceOrientation.portraitDown;
}
