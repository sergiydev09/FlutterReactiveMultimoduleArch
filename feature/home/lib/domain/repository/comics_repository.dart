import 'package:home/domain/model/comic_model.dart';
import 'package:injectable/injectable.dart';

abstract class ComicRepository {
  Future<List<ComicModel>> getComics();
}