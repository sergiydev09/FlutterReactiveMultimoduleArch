import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/services.dart';

/// Prevents screen capture and recording on sensitive screens.
///
/// - **Android**: Uses `FLAG_SECURE` via platform channel.
/// - **iOS**: Uses `UITextField.isSecureTextEntry` trick to trigger
///   system-level screen protection.
class ScreenProtectionService {
  ScreenProtectionService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('com.company.app/screen');

  final MethodChannel _channel;

  static const _tag = 'ScreenProtection';

  bool _isProtected = false;

  /// Whether screen protection is currently active.
  bool get isProtected => _isProtected;

  /// Enables screen capture/recording protection.
  ///
  /// On Android this sets `FLAG_SECURE` on the window.
  /// On iOS this adds a secure text field overlay.
  Future<void> enable() async {
    if (_isProtected) return;
    try {
      await _channel.invokeMethod<void>('enableProtection');
      _isProtected = true;
      developer.log('Screen protection enabled', name: _tag);
    } on PlatformException catch (e) {
      developer.log(
        'Failed to enable screen protection: $e',
        name: _tag,
      );
    }
  }

  /// Disables screen capture/recording protection.
  Future<void> disable() async {
    if (!_isProtected) return;
    try {
      await _channel.invokeMethod<void>('disableProtection');
      _isProtected = false;
      developer.log('Screen protection disabled', name: _tag);
    } on PlatformException catch (e) {
      developer.log(
        'Failed to disable screen protection: $e',
        name: _tag,
      );
    }
  }

  /// Returns `true` if the current platform supports screen protection.
  bool get isSupported => Platform.isAndroid || Platform.isIOS;
}
