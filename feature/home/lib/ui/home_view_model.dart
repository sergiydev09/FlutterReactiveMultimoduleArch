import 'package:arch/ui/state_notifier.dart';
import 'package:home/domain/repository/comics_repository.dart';
import 'package:home/ui/home_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeViewModel {
  final ComicRepository _comicRepository;

  HomeViewModel(this._comicRepository) {
    _getComics();
  }

  final StateNotifier<HomeState> state = StateNotifier<HomeState>(HomeState());

  _getComics() async {
    _comicRepository.getComics().listen((comics) {
      state.update((currentState) => currentState.copy(comics: comics));
    }, onError: (error) {
      // Manejo de errores, por ejemplo, actualizando el estado para mostrar un error.
      print("Error al cargar cómics: $error");
    }, onDone: () {
      // Acciones al completar la carga de todos los cómics, si es necesario.
      print("Carga de cómics completada");
    });
  }
}
