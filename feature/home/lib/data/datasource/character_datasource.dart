import 'dart:convert';

import 'package:home/data/datasource/dto/character_dto.dart';
import 'package:home/data/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@injectable
class CharactersDataSource {
  Stream<List<CharacterDTO>> fetchCharacters(List<String> characterUris) async* {
    var batchSize = 3;
    for (var i = 0; i < characterUris.length; i += batchSize) {
      var batch = characterUris.skip(i).take(batchSize);
      var batchResults = await Future.wait(batch.map((uri) {
        return http.get(MarvelAuth.buildUri(uri));
      }));

      List<CharacterDTO> creatorsBatch = [];
      for (var response in batchResults) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          var results = data['data']['results'] as List;
          creatorsBatch.addAll(results.map((json) => CharacterDTO.fromJson(json)).toList());
        }
      }
      yield creatorsBatch;
    }
  }

}

