import 'dart:async';

import 'package:home/data/datasource/character_datasource.dart';
import 'package:home/data/datasource/comics_datasource.dart';
import 'package:home/data/datasource/creator_datasource.dart';
import 'package:home/data/datasource/dto/comic_dto.dart';
import 'package:home/domain/model/character_model.dart';
import 'package:home/domain/model/comic_model.dart';
import 'package:home/domain/model/creator_model.dart';
import 'package:home/domain/model/price_model.dart';
import 'package:home/domain/repository/comics_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ComicRepository)
class ComicRepositoryImpl implements ComicRepository {
  final ComicsDataSource _comicsDataSource;
  final CreatorsDataSource _creatorsDataSource;
  final CharactersDataSource _charactersDataSource;

  ComicRepositoryImpl(this._comicsDataSource, this._creatorsDataSource, this._charactersDataSource);

  @override
  Stream<List<ComicModel>> getComics() async* {
    final comicDTOs = await _comicsDataSource.fetchComics();
    Map<int, ComicModel> comicsMap = {};

    var comicsStreamController = StreamController<List<ComicModel>>();

    for (var comicDto in comicDTOs) {
      comicsMap[comicDto.id] = transformToDomainModel(comicDto);

      _creatorsDataSource.fetchCreators(comicDto.creators).listen((batchCreatorDTOs) {
        var comic = comicsMap[comicDto.id];
        if (comic != null) {
          List<CreatorModel> newCreatorModels = batchCreatorDTOs.map((creatorDto) {
            final thumbnailPath = creatorDto.thumbnailPath;
            return CreatorModel(name: creatorDto.fullName, imagePath: thumbnailPath);
          }).toList();
          List<CreatorModel> creatorModels = [...comic.creators, ...newCreatorModels];

          comicsMap[comicDto.id] = comic.copyWith(creators: creatorModels);
          comicsStreamController.add(comicsMap.values.toList());
        }
      });

      _charactersDataSource.fetchCharacters(comicDto.characters).listen((batchCharacters) {
        var comic = comicsMap[comicDto.id];
        if (comic != null) {
          List<CharacterModel> newBatchCharactersModels = batchCharacters.map((characterDto) {
            final thumbnailPath = characterDto.thumbnailPath;
            return CharacterModel(name: characterDto.name, imagePath: thumbnailPath);
          }).toList();

          List<CharacterModel> characterModels = [...comic.characters, ...newBatchCharactersModels];
          comicsMap[comicDto.id] = comic.copyWith(characters: characterModels);
          comicsStreamController.add(comicsMap.values.toList());
        }
      });
    }

    yield* comicsStreamController.stream;
  }

  ComicModel transformToDomainModel(ComicDTO comicDto) {
    final priceModel = PriceModel.fromJson(comicDto.prices.firstWhere((price) => price['type'] == 'printPrice'));
    return ComicModel(
      id: comicDto.id,
      title: comicDto.title,
      description: comicDto.description,
      imagePath: comicDto.thumbnailPath,
      pageCount: comicDto.pageCount,
      price: priceModel,
      creators: [],
      characters: [],
    );
  }
}
