import 'package:flutter/foundation.dart';

class StateNotifier<T> extends ValueNotifier<T> {
  StateNotifier(super.value);

  update(Function(T) updateFunction) {
    T currentStateCopy = updateFunction(value);
    value = currentStateCopy;
  }
}
