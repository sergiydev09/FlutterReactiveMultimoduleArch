import 'package:flutter/foundation.dart';
import 'package:home/domain/repository/comics_repository.dart';
import 'package:home/ui/home_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeViewModel {
  final ComicRepository _comicRepository;

  HomeViewModel(this._comicRepository);

  final ValueNotifier<HomeState> state = ValueNotifier(HomeState());

  getComics() {
    _comicRepository.getComics().then((comics) {
      state.value = state.value.updateWith(comics: comics);
    });
  }
}
