import 'package:bloc_test/bloc_test.dart';
import 'package:common/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:main_shell/domain/entities/shell_config.dart';
import 'package:main_shell/domain/repositories/shell_config_repository.dart';
import 'package:main_shell/domain/repositories/shell_session_repository.dart';
import 'package:main_shell/domain/usecases/get_shell_config_usecase.dart';
import 'package:main_shell/domain/usecases/shell_logout_usecase.dart';
import 'package:main_shell/presentation/shell/bloc/main_shell_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockShellConfigRepository extends Mock implements ShellConfigRepository {}

class MockShellSessionRepository extends Mock implements ShellSessionRepository {}

const _emptyConfig = ShellConfig(drawerItems: [], bottomTabs: []);

void main() {
  late MockShellConfigRepository configRepository;
  late MockShellSessionRepository sessionRepository;
  late GetShellConfigUseCase getShellConfigUseCase;
  late ShellLogoutUseCase logoutUseCase;

  setUp(() {
    configRepository = MockShellConfigRepository();
    sessionRepository = MockShellSessionRepository();
    getShellConfigUseCase =
        GetShellConfigUseCase(repository: configRepository);
    logoutUseCase = ShellLogoutUseCase(repository: sessionRepository);
  });

  MainShellBloc buildBloc() => MainShellBloc(
        getShellConfigUseCase: getShellConfigUseCase,
        logoutUseCase: logoutUseCase,
      );

  group('ShellStarted', () {
    blocTest<MainShellBloc, MainShellState>(
      'emits loading then ready with config on success',
      setUp: () => when(() => configRepository.getShellConfig())
          .thenAnswer((_) async => const Right(_emptyConfig)),
      build: buildBloc,
      act: (bloc) => bloc.add(const ShellStarted()),
      expect: () => [
        const MainShellState(),
        const MainShellState(
          status: MainShellStatus.ready,
          config: _emptyConfig,
        ),
      ],
    );

    blocTest<MainShellBloc, MainShellState>(
      'emits loading then error when config load fails',
      setUp: () => when(() => configRepository.getShellConfig()).thenAnswer(
        (_) async =>
            const Left(Failure.server(message: 'Config unavailable')),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const ShellStarted()),
      expect: () => [
        const MainShellState(),
        const MainShellState(
          status: MainShellStatus.error,
          errorMessage:
              'Failure.server(message: Config unavailable, statusCode: null)',
        ),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<MainShellBloc, MainShellState>(
      'does not emit new state on successful logout '
      '(GoRouter.redirect handles navigation)',
      setUp: () => when(() => sessionRepository.logout())
          .thenAnswer((_) async => const Right(null)),
      build: buildBloc,
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => <MainShellState>[],
    );

    blocTest<MainShellBloc, MainShellState>(
      'emits error state when logout fails',
      setUp: () => when(() => sessionRepository.logout()).thenAnswer(
        (_) async => const Left(Failure.server(message: 'Logout failed')),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const MainShellState(
          status: MainShellStatus.error,
          errorMessage:
              'Failure.server(message: Logout failed, statusCode: null)',
        ),
      ],
    );
  });
}
