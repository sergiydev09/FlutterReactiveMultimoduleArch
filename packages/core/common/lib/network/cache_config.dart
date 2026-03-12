import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// Provides default cache configuration using an in-memory store.
class CacheConfig {
  const CacheConfig._();

  /// Default cache options using [MemCacheStore].
  ///
  /// Cached responses are kept for 5 minutes by default.
  static CacheOptions get defaultOptions => CacheOptions(
    store: MemCacheStore(),
    hitCacheOnNetworkFailure: true,
    maxStale: const Duration(minutes: 5),
  );
}
