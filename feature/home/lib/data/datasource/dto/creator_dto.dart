class CreatorDTO {
  final int id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final String fullName;
  final String modified;
  final String thumbnailPath;

  CreatorDTO({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.suffix,
    required this.fullName,
    required this.modified,
    required this.thumbnailPath,
  });

  factory CreatorDTO.fromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'];
    return CreatorDTO(
      id: json['id'],
      firstName: json['firstName'],
      middleName: json['middleName'] ?? '',
      lastName: json['lastName'],
      suffix: json['suffix'] ?? '',
      fullName: json['fullName'],
      modified: json['modified'],
      thumbnailPath: "${thumbnail['path']}.${thumbnail['extension']}",
    );
  }
}
