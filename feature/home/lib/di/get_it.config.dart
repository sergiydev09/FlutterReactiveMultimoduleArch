// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../data/datasource/character_datasource.dart' as _i3;
import '../data/datasource/comics_datasource.dart' as _i4;
import '../data/datasource/creator_datasource.dart' as _i5;
import '../data/repository/comics_repository_impl.dart' as _i7;
import '../domain/repository/comics_repository.dart' as _i6;
import '../ui/home_view_model.dart' as _i8;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i3.CharactersDataSource>(() => _i3.CharactersDataSource());
    gh.factory<_i4.ComicsDataSource>(() => _i4.ComicsDataSource());
    gh.factory<_i5.CreatorsDataSource>(() => _i5.CreatorsDataSource());
    gh.factory<_i6.ComicRepository>(() => _i7.ComicRepositoryImpl(
          gh<_i4.ComicsDataSource>(),
          gh<_i5.CreatorsDataSource>(),
          gh<_i3.CharactersDataSource>(),
        ));
    gh.factory<_i8.HomeViewModel>(
        () => _i8.HomeViewModel(gh<_i6.ComicRepository>()));
    return this;
  }
}
