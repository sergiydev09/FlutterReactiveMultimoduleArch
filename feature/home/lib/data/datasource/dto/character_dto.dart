class CharacterDTO {
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
}

