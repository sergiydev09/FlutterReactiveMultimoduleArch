import 'package:arch/data/cache_data_source.dart';

class CreatorDTO implements CacheMappable {
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

  @override
  Map<String, dynamic> toStorageMap() {
    return {
      'id': id,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'suffix': suffix,
      'fullName': fullName,
      'modified': modified,
      'thumbnailPath': thumbnailPath,
    };
  }

  @override
  factory CreatorDTO.fromStorageMap(Map<String, dynamic> map) {
    return CreatorDTO(
      id: map['id'],
      firstName: map['firstName'],
      middleName: map['middleName'],
      lastName: map['lastName'],
      suffix: map['suffix'],
      fullName: map['fullName'],
      modified: map['modified'],
      thumbnailPath: map['thumbnailPath'],
    );
  }

}
