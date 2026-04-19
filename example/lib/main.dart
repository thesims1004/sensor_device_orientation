import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensor_device_orientation/sensor_device_orientation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock the screen to portrait so we can clearly demonstrate that this
  // package detects physical orientation independently of screen orientation.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sensor_device_orientation demo',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('sensor_device_orientation'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _Hint(),
              SizedBox(height: 16),
              _CurrentValueCard(),
              SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _RotatedBoxDemo()),
                    SizedBox(width: 16),
                    Expanded(child: _AnimatedDemo()),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _IconRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock, color: Colors.amber, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Screen is locked to portrait. Tilt the device — '
              'all rotated elements below should follow.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Demonstrates the `Stream` API.
class _CurrentValueCard extends StatelessWidget {
  const _CurrentValueCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorDeviceOrientation>(
      stream: SensorDeviceOrientationDetector.instance.stream,
      initialData: SensorDeviceOrientationDetector.instance.value,
      builder: (context, snapshot) {
        final orientation = snapshot.data ?? SensorDeviceOrientation.portraitUp;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stream API',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(_iconFor(orientation),
                      size: 32, color: Colors.cyanAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orientation.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'quarterTurns: ${orientation.quarterTurns}  •  '
                          '${orientation.isLandscape ? "landscape" : orientation.isPortrait ? "portrait" : "flat"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _iconFor(SensorDeviceOrientation o) {
    switch (o) {
      case SensorDeviceOrientation.portraitUp:
        return Icons.stay_current_portrait;
      case SensorDeviceOrientation.portraitDown:
        return Icons.crop_portrait;
      case SensorDeviceOrientation.landscapeLeft:
        return Icons.stay_current_landscape;
      case SensorDeviceOrientation.landscapeRight:
        return Icons.stay_primary_landscape;
      case SensorDeviceOrientation.flat:
        return Icons.tablet_mac;
    }
  }
}

/// Demonstrates `SensorRotatedBox` (instant snap).
class _RotatedBoxDemo extends StatelessWidget {
  const _RotatedBoxDemo();

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      label: 'SensorRotatedBox',
      child: SensorRotatedBox(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'TOP',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Demonstrates `SensorRotatedBox` with `animate: true`.
class _AnimatedDemo extends StatelessWidget {
  const _AnimatedDemo();

  @override
  Widget build(BuildContext context) {
    return const _DemoCard(
      label: 'animate: true',
      child: SensorRotatedBox(
        animate: true,
        duration: Duration(milliseconds: 350),
        child: Icon(
          Icons.arrow_upward,
          size: 64,
          color: Colors.greenAccent,
        ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _DemoCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: Center(child: child)),
        ],
      ),
    );
  }
}

/// Demonstrates `SensorDeviceOrientationBuilder` — multiple rotated icons
/// sharing a single sensor subscription.
class _IconRow extends StatelessWidget {
  const _IconRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SensorDeviceOrientationBuilder (camera-app style icons)',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          SensorDeviceOrientationBuilder(
            builder: (context, orientation) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final icon in const [
                    Icons.flash_on,
                    Icons.timer,
                    Icons.grid_on,
                    Icons.date_range,
                    Icons.cameraswitch,
                  ])
                    AnimatedRotation(
                      turns: orientation.quarterTurns / 4.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: Icon(icon, size: 28),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
