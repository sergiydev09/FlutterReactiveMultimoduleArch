import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CacheManager {
  static const _storage = FlutterSecureStorage();
  static final Map<String, dynamic> _inMemoryCache = {};
  static final Map<String, DateTime> _expirationTimes = {};

  static Future<void> add<T extends CacheMappable>(String key, T value,
      {CachePersistenceMode mode = CachePersistenceMode.persistForever, Duration? duration}) async {
    switch (mode) {
      case CachePersistenceMode.volatile:
        _inMemoryCache[key] = value;
        break;
      case CachePersistenceMode.persistForever:
      case CachePersistenceMode.persistWithTimeout:
        _inMemoryCache[key] = value;
        final jsonData = jsonEncode(value.toStorageMap());
        await _storage.write(key: key, value: jsonData);

        if (mode == CachePersistenceMode.persistWithTimeout && duration != null) {
          _expirationTimes[key] = DateTime.now().add(duration);
        }
        break;
    }
  }

  static Future<void> addList<T extends CacheMappable>(String key, List<T> values,
      {CachePersistenceMode mode = CachePersistenceMode.persistForever, Duration? duration}) async {
    _inMemoryCache[key] = values;
    final jsonData = jsonEncode(values.map((value) => value.toStorageMap()).toList());
    await _storage.write(key: key, value: jsonData);

    if (mode == CachePersistenceMode.persistWithTimeout && duration != null) {
      _expirationTimes[key] = DateTime.now().add(duration);
    }
  }

  static Future<T?> get<T extends CacheMappable>(String key, T Function(Map<String, dynamic>) fromStorageMap) async {
    if (_expirationTimes.containsKey(key) && _expirationTimes[key]!.isBefore(DateTime.now())) {
      _inMemoryCache.remove(key);
      _expirationTimes.remove(key);
      await _storage.delete(key: key);
      return null;
    }

    if (_inMemoryCache.containsKey(key)) {
      return _inMemoryCache[key] as T;
    }

    final stringData = await _storage.read(key: key);
    if (stringData == null) return null;

    final Map<String, dynamic> mapData = jsonDecode(stringData);
    final T value = fromStorageMap(mapData);

    _inMemoryCache[key] = value;
    return value;
  }

  static Future<List<T>?> getList<T extends CacheMappable>(
      String key, T Function(Map<String, dynamic>) fromStorageMap) async {
    if (_expirationTimes.containsKey(key) && _expirationTimes[key]!.isBefore(DateTime.now())) {
      _inMemoryCache.remove(key);
      _expirationTimes.remove(key);
      await _storage.delete(key: key);
      return null;
    }

    if (_inMemoryCache.containsKey(key)) {
      return List<T>.from(_inMemoryCache[key]);
    }

    final stringData = await _storage.read(key: key);
    if (stringData == null) return null;

    final List<dynamic> listData = jsonDecode(stringData);
    final List<T> values = listData.map((mapData) => fromStorageMap(mapData as Map<String, dynamic>)).toList();

    _inMemoryCache[key] = values;
    return values;
  }

  static Future<void> remove(String key) async {
    _inMemoryCache.remove(key);
    _expirationTimes.remove(key);
    await _storage.delete(key: key);
  }
}

enum CachePersistenceMode {
  volatile,
  persistForever,
  persistWithTimeout,
}

abstract class CacheMappable<T> {
  factory CacheMappable.fromStorageMap(Map<String, dynamic> map) => throw UnimplementedError();

  Map<String, dynamic> toStorageMap();
}
