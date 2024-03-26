import 'package:arch/data/cache_data_source.dart';

class CharacterDTO implements CacheMappable {
  final int id;
  final String name;
  final String description;
  final String modified;
  final String thumbnailPath;

  CharacterDTO({
    required this.id,
    required this.name,
    this.description = "",
    required this.modified,
    required this.thumbnailPath,
  });

  factory CharacterDTO.fromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'];
    return CharacterDTO(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      modified: json['modified'],
      thumbnailPath: "${thumbnail['path']}.${thumbnail['extension']}",
    );
  }

  @override
  Map<String, dynamic> toStorageMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'modified': modified,
      'thumbnailPath': thumbnailPath,
    };
  }

  @override
  factory CharacterDTO.fromStorageMap(Map<String, dynamic> map) {
    return CharacterDTO(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      modified: map['modified'],
      thumbnailPath: map['thumbnailPath'],
    );
  }

}

