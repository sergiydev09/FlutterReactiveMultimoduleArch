import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

/// Copies sensitive data to the clipboard and automatically clears it
/// after a configurable delay.
///
/// Prevents IBAN, card numbers, and other sensitive data from lingering
/// in the system clipboard.
class ClipboardProtectionService {
  static const _tag = 'ClipboardProtection';

  /// Default time before the clipboard is cleared.
  static const defaultClearDelay = Duration(seconds: 30);

  Timer? _clearTimer;

  /// Copies [data] to the clipboard and schedules automatic clearing
  /// after [clearAfter].
  Future<void> copyWithProtection(
    String data, {
    Duration clearAfter = defaultClearDelay,
  }) async {
    // Cancel any pending clear from a previous copy.
    _clearTimer?.cancel();

    await Clipboard.setData(ClipboardData(text: data));
    developer.log(
      'Sensitive data copied, will clear in ${clearAfter.inSeconds}s',
      name: _tag,
    );

    _clearTimer = Timer(clearAfter, () async {
      await clear();
    });
  }

  /// Immediately clears the clipboard.
  Future<void> clear() async {
    _clearTimer?.cancel();
    _clearTimer = null;
    await Clipboard.setData(const ClipboardData(text: ''));
    developer.log('Clipboard cleared', name: _tag);
  }

  /// Cancels any pending clipboard clear timer.
  void dispose() {
    _clearTimer?.cancel();
    _clearTimer = null;
  }
}
