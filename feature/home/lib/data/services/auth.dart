import 'dart:convert';

import 'package:crypto/crypto.dart';

//Key 1
// static const String _apiKey = 'e00fbf8229a063c30bf7daf3173716ea';
// static const String _privateKey = '2cadc3a6e0749c79bf4794a4c080a696edd28a2d';

//Key 2
// static const String _apiKey = 'd2b292514da4c74bc27d85aca297c7d4';
// static const String _privateKey = '709e36b6189bd2982a96ed5fe0bb9d9d62fe632b';

//Key 3
// static const String _apiKey = '1073f46987d0b1a66fb72754d423b54c';
// static const String _privateKey = 'a6144aeda210e607654140447495bb8e93bbe699';

class MarvelAuth {
  static const String _apiKey = '78a919b737c9c5d21c5b4e84c2599068';
  static const String _privateKey = '431f36773b14d717fd132df1e56d3cad222ceae1';

  static String get _timestamp => '1';

  static String generateHash() {
    final String toHash = _timestamp + _privateKey + _apiKey;
    return md5.convert(utf8.encode(toHash)).toString();
  }

  static Uri buildUri(String basePath, [Map<String, dynamic>? extraParams]) {
    final Map<String, dynamic> defaultParams = {
      'ts': _timestamp,
      'apikey': _apiKey,
      'hash': generateHash(),
    };

    final uri = Uri.parse(basePath).replace(queryParameters: {
      ...defaultParams,
      ...?extraParams,
    });

    return uri;
  }
}
