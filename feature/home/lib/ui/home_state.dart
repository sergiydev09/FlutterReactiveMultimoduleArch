import 'package:home/domain/model/comic_model.dart';

class HomeState {
  final List<ComicModel> comics;
  final bool loading;

  HomeState({this.comics = const [], this.loading = false});

  HomeState copy({List<ComicModel>? comics, bool? loading}) =>
      HomeState(comics: comics ?? this.comics, loading: loading ?? this.loading);
}
