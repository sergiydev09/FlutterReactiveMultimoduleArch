import 'package:home/domain/model/comic_model.dart';

class HomeState {
  List<ComicModel> comics = [];

  HomeState({this.comics = const []});

  HomeState updateWith({required List<ComicModel> comics}) => HomeState(comics: comics);

}
