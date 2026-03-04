import 'dart:math';
import './mock_config.dart';

class MockDelay {
  static Future<void> simulate(MockConfig config) async {
    final random = Random();
    final delay =
        config.minDelayMs +
        random.nextInt(config.maxDelayMs - config.minDelayMs + 1);
    await Future<void>.delayed(Duration(milliseconds: delay));
  }
}
