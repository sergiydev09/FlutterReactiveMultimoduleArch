import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around [FlutterSecureStorage] for secure key-value storage.
///
/// Provides platform-specific options for Android (encrypted shared prefs)
/// and iOS (Keychain accessibility).
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _tag = 'SecureStorage';

  /// Writes a [value] for the given [key].
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on Exception catch (e, st) {
      developer.log(
        'Failed to write key "$key": $e',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Reads the value for the given [key]. Returns `null` if not found.
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } on Exception catch (e, st) {
      developer.log(
        'Failed to read key "$key": $e',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Deletes the value for the given [key].
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on Exception catch (e, st) {
      developer.log(
        'Failed to delete key "$key": $e',
        name: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Deletes all stored values.
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } on Exception catch (e, st) {
      developer.log(
        'Failed to delete all keys: $e',
        name: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Checks whether a value exists for the given [key].
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } on Exception catch (_) {
      return false;
    }
  }
}
