import 'dart:convert';

import 'package:arch/data/cache_data_source.dart';
import 'package:home/data/datasource/dto/comic_dto.dart';
import 'package:home/data/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@injectable
class ComicsDataSource {
  Future<List<ComicDTO>> fetchComics() async {
    final cachedComics = await CacheManager.getList("comics", ComicDTO.fromStorageMap);

    if (cachedComics != null && cachedComics.isNotEmpty) {
      return cachedComics;
    }

    final uri = MarvelAuth.buildUri('https://gateway.marvel.com/v1/public/comics');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['data']['results'] as List;
      List<ComicDTO> comics = results.map((json) => ComicDTO.fromJson(json)).toList();

      CacheManager.addList("comics", comics);

      return comics;
    } else {
      throw Exception('Failed to load comics');
    }
  }
}
