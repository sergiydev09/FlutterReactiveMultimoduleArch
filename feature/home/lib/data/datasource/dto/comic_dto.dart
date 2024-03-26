import 'package:arch/data/cache_data_source.dart';

class ComicDTO implements CacheMappable {
  final int id;
  final String title;
  final String? description;
  final String thumbnailPath;
  final int pageCount;
  final List<dynamic> prices;
  final List<String> creators;
  final List<String> characters;

  ComicDTO({
    required this.id,
    required this.title,
    this.description,
    required this.thumbnailPath,
    required this.pageCount,
    required this.prices,
    required this.creators,
    required this.characters,
  });

  factory ComicDTO.fromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'];
    final imagePath = "${thumbnail['path']}.${thumbnail['extension']}";

    List<String> creatorUris = [];
    if (json['creators'] != null && json['creators']['items'] != null) {
      var items = json['creators']['items'] as List<dynamic>;
      creatorUris = items.map((item) => item['resourceURI'] as String).toList();
    }

    List<String> charactersUris = [];
    if (json['characters'] != null && json['characters']['items'] != null) {
      var items = json['characters']['items'] as List<dynamic>;
      charactersUris = items.map((item) => item['resourceURI'] as String).toList();
    }

    return ComicDTO(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailPath: imagePath,
      pageCount: json['pageCount'],
      prices: json['prices'],
      creators: creatorUris,
      characters: charactersUris,
    );
  }

  @override
  Map<String, dynamic> toStorageMap() {
    return {
      'id': id,
      'title': title,
      'description': description ?? '',
      'thumbnailPath': thumbnailPath,
      'pageCount': pageCount,
      'prices': prices,
      'creators': creators,
      'characters': characters,
    };
  }

  @override
  factory ComicDTO.fromStorageMap(Map<String, dynamic> map) {
    return ComicDTO(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      thumbnailPath: map['thumbnailPath'],
      pageCount: map['pageCount'],
      prices: map['prices'],
      creators: List<String>.from(map['creators']),
      characters: List<String>.from(map['characters']),
    );
  }
}
