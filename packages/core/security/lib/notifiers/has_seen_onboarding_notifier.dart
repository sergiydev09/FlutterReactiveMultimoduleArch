import 'package:flutter_riverpod/flutter_riverpod.dart';

class HasSeenOnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  // Method used to update state from outside the notifier.
  // ignore: use_setters_to_change_properties
  void set({required bool value}) => state = value;
}
