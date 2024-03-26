import 'dart:convert';

import 'package:arch/data/cache_data_source.dart';
import 'package:home/data/datasource/dto/character_dto.dart';
import 'package:home/data/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@injectable
class CharactersDataSource {
  Stream<List<CharacterDTO>> fetchCharacters(int comicId, List<String> characterUris) async* {
    final cacheId = "${comicId}_characters";

    final cachedCharacters = await CacheManager.getList(cacheId, CharacterDTO.fromStorageMap);

    if (cachedCharacters != null && cachedCharacters.isNotEmpty) {
      yield cachedCharacters;
    } else {
      var batchSize = 3;
      List<CharacterDTO> characters = [];
      for (var i = 0; i < characterUris.length; i += batchSize) {
        var batch = characterUris.skip(i).take(batchSize);
        var batchResults = await Future.wait(batch.map((uri) {
          return http.get(MarvelAuth.buildUri(uri));
        }));

        for (var response in batchResults) {
          if (response.statusCode == 200) {
            var data = json.decode(response.body);
            var results = data['data']['results'] as List;
            characters.addAll(results.map((json) => CharacterDTO.fromJson(json)).toList());
          }
        }
        await CacheManager.addList(cacheId, characters);
        yield characters;
      }
    }
  }
}
