import 'package:home/domain/model/comic_model.dart';

abstract class ComicRepository {
  Stream<List<ComicModel>> getComics();
}