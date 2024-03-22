import 'package:home/domain/model/character_model.dart';
import 'package:home/domain/model/creator_model.dart';
import 'package:home/domain/model/price_model.dart';

class ComicModel {
  final int id;
  final String title;
  final String? description;
  final String imagePath;
  final int pageCount;
  final PriceModel price;
  final List<CreatorModel> creators;
  final List<CharacterModel> characters;

  ComicModel({
    required this.id,
    required this.title,
    this.description,
    required this.imagePath,
    required this.pageCount,
    required this.price,
    required this.creators,
    required this.characters,
  });

  factory ComicModel.fromJson(Map<String, dynamic> json, List<CreatorModel> creators, List<CharacterModel> characters) {
    final thumbnail = json['thumbnail'];
    final imagePath = '${thumbnail['path']}.${thumbnail['extension']}';
    final pricesJson = json['prices'] as List;
    final price = PriceModel.fromJson(pricesJson.first);

    return ComicModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imagePath: imagePath,
      pageCount: json['pageCount'],
      price: price,
      creators: creators,
      characters: characters,
    );
  }
}
