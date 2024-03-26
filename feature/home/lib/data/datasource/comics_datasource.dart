import 'dart:convert';
import 'package:home/data/datasource/dto/comic_dto.dart';
import 'package:home/data/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@injectable
class ComicsDataSource {
  Future<List<ComicDTO>> fetchComics() async {
    final uri = MarvelAuth.buildUri('http://gateway.marvel.com/v1/public/comics');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['data']['results'] as List;
      return results.map((json) => ComicDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comics');
    }
  }
}
