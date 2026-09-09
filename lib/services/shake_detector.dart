import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

/// Listens to the device accelerometer and calls [onShake] when a
/// shake gesture is detected, based on a threshold on combined
/// acceleration force.
class ShakeDetector {
  final void Function() onShake;
  final double shakeThreshold;

  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastShakeTime;

  ShakeDetector({
    required this.onShake,
    this.shakeThreshold = 15.0,
  });

  void start() {
    _subscription = accelerometerEventStream().listen((event) {
      final double force =
          (event.x * event.x + event.y * event.y + event.z * event.z);
      final double magnitude = force > 0 ? force : 0;

      // Roughly 9.8^2 * 3 ≈ 288 is "at rest" on all axes combined.
      // We compare against a threshold above normal gravity noise.
      if (magnitude > shakeThreshold * shakeThreshold) {
        final now = DateTime.now();
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!) > const Duration(seconds: 1)) {
          _lastShakeTime = now;
          onShake();
        }
      }
    });
  }

  void stop() {
    _subscription?.cancel();
  }
}