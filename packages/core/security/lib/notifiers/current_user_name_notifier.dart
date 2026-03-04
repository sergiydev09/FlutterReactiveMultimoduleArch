import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentUserNameNotifier extends Notifier<String> {
  @override
  String build() => '';

  // Method used to update state from outside the notifier.
  // ignore: use_setters_to_change_properties
  void set(String value) => state = value;
}
