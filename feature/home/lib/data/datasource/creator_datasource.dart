import 'dart:convert';

import 'package:arch/data/cache_data_source.dart';
import 'package:home/data/datasource/dto/creator_dto.dart';
import 'package:home/data/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@injectable
class CreatorsDataSource {
  Stream<List<CreatorDTO>> fetchCreators(int comicId, List<String> creatorUris) async* {
    final cacheId = "${comicId}_creators";
    final cachedCreators = await CacheManager.getList(cacheId, CreatorDTO.fromStorageMap);

    if (cachedCreators != null && cachedCreators.isNotEmpty) {
      yield cachedCreators;
    } else {
      var batchSize = 3;
      List<CreatorDTO> creators = [];
      for (var i = 0; i < creatorUris.length; i += batchSize) {
        var batch = creatorUris.skip(i).take(batchSize);
        var batchResults = await Future.wait(batch.map((uri) {
          return http.get(MarvelAuth.buildUri(uri));
        }));

        for (var response in batchResults) {
          if (response.statusCode == 200) {
            var data = json.decode(response.body);
            var results = data['data']['results'] as List;
            creators.addAll(results.map((json) => CreatorDTO.fromJson(json)).toList());
          }
        }
        await CacheManager.addList(cacheId, creators);
        yield creators;
      }
    }
  }
}
