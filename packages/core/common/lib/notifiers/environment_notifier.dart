import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/environment.dart';

class EnvironmentNotifier extends Notifier<Environment> {
  @override
  Environment build() => Environment.mock;

  // Method used to update state from outside the notifier.
  // ignore: use_setters_to_change_properties
  void set(Environment value) => state = value;
}
