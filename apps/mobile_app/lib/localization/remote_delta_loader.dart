import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

/// Asset loader that merges bundled translations with remote JSON deltas.
///
/// On startup it loads the bundled [path]/<locale>.json, then attempts to
/// fetch a delta from [deltaBaseUrl]/<locale>.json and deep-merges any
/// overrides from the remote response. If the network request fails the
/// bundled translations are returned unchanged, ensuring the app always works
/// offline.
class RemoteDeltaLoader extends AssetLoader {
  const RemoteDeltaLoader({this.deltaBaseUrl});

  /// Base URL from which `<locale>.json` delta files are fetched.
  /// Pass `null` to skip remote fetching (e.g. in dev/local environments).
  final String? deltaBaseUrl;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final bundledJson =
        await rootBundle.loadString('$path/${locale.languageCode}.json');
    final bundled = json.decode(bundledJson) as Map<String, dynamic>;

    if (deltaBaseUrl == null) return bundled;

    try {
      final response = await Dio().get<Map<String, dynamic>>(
        '$deltaBaseUrl/${locale.languageCode}.json',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        return _deepMerge(bundled, response.data!);
      }
    } catch (_) {
      // Network unavailable or server error – fall back to bundled strings.
    }

    return bundled;
  }

  Map<String, dynamic> _deepMerge(
    Map<String, dynamic> base,
    Map<String, dynamic> delta,
  ) {
    final result = Map<String, dynamic>.from(base);
    for (final entry in delta.entries) {
      if (result[entry.key] is Map<String, dynamic> &&
          entry.value is Map<String, dynamic>) {
        result[entry.key] = _deepMerge(
          result[entry.key] as Map<String, dynamic>,
          entry.value as Map<String, dynamic>,
        );
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}
