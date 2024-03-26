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

  ComicModel copyWith({
    String? title,
    String? description,
    String? imagePath,
    int? pageCount,
    PriceModel? price,
    List<CreatorModel>? creators,
    List<CharacterModel>? characters,
  }) {
    return ComicModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      pageCount: pageCount ?? this.pageCount,
      price: price ?? this.price,
      creators: creators ?? this.creators,
      characters: characters ?? this.characters,
    );
  }

}
