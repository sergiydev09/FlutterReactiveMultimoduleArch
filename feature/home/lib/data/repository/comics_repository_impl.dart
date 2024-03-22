import 'package:injectable/injectable.dart';
import 'package:home/domain/model/comic_model.dart';
import 'package:home/domain/repository/comics_repository.dart';

@Injectable(as: ComicRepository)
class ComicRepositoryImpl implements ComicRepository {

  @override
  Future<List<ComicModel>> getComics() async {
    return [];
  }

}
