import 'package:bloc_test/bloc_test.dart';
import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:security/security.dart';
import 'package:settings/domain/repositories/settings_repository.dart';
import 'package:settings/domain/usecases/get_biometrics_status_usecase.dart';
import 'package:settings/domain/usecases/toggle_biometrics_usecase.dart';
import 'package:settings/presentation/settings/bloc/settings_bloc.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockLogoutDataSource extends Mock implements LogoutDataSource {}

void main() {
  late MockSettingsRepository repository;
  late MockLogoutDataSource logoutDataSource;
  late GetBiometricsStatusUseCase getBiometricsStatusUseCase;
  late ToggleBiometricsUseCase toggleBiometricsUseCase;
  late LogoutUseCase logoutUseCase;

  setUp(() {
    repository = MockSettingsRepository();
    logoutDataSource = MockLogoutDataSource();
    getBiometricsStatusUseCase =
        GetBiometricsStatusUseCase(repository: repository);
    toggleBiometricsUseCase =
        ToggleBiometricsUseCase(repository: repository);
    logoutUseCase = LogoutUseCase(logoutDataSource: logoutDataSource);
  });

  SettingsBloc buildBloc() => SettingsBloc(
        getBiometricsStatusUseCase: getBiometricsStatusUseCase,
        toggleBiometricsUseCase: toggleBiometricsUseCase,
        logoutUseCase: logoutUseCase,
      );

  group('SettingsStarted', () {
    blocTest<SettingsBloc, SettingsState>(
      'emits loaded with biometrics enabled when repository returns true',
      setUp: () => when(() => repository.getBiometricsEnabled())
          .thenAnswer((_) async => const Right(true)),
      build: buildBloc,
      act: (bloc) => bloc.add(const SettingsStarted()),
      expect: () => [
        const SettingsState(status: SettingsStatus.loading),
        const SettingsState(
          status: SettingsStatus.loaded,
          isBiometricsEnabled: true,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits loaded with biometrics disabled when repository returns false',
      setUp: () => when(() => repository.getBiometricsEnabled())
          .thenAnswer((_) async => const Right(false)),
      build: buildBloc,
      act: (bloc) => bloc.add(const SettingsStarted()),
      expect: () => [
        const SettingsState(status: SettingsStatus.loading),
        const SettingsState(status: SettingsStatus.loaded),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits error when repository fails',
      setUp: () => when(() => repository.getBiometricsEnabled()).thenAnswer(
        (_) async => const Left(Failure.server(message: 'Storage error')),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const SettingsStarted()),
      expect: () => [
        const SettingsState(status: SettingsStatus.loading),
        const SettingsState(
          status: SettingsStatus.error,
          errorMessage: 'Storage error',
        ),
      ],
    );
  });

  group('ToggleTheme', () {
    blocTest<SettingsBloc, SettingsState>(
      'toggles isDarkMode from false to true',
      build: buildBloc,
      act: (bloc) => bloc.add(const ToggleTheme()),
      expect: () => [
        const SettingsState(isDarkMode: true),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'toggles isDarkMode back to false on second event',
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const ToggleTheme())
          ..add(const ToggleTheme());
      },
      expect: () => [
        const SettingsState(isDarkMode: true),
        const SettingsState(),
      ],
    );
  });

  group('ToggleBiometrics', () {
    blocTest<SettingsBloc, SettingsState>(
      'emits loaded with new biometric value from repository',
      setUp: () => when(() => repository.toggleBiometrics())
          .thenAnswer((_) async => const Right(true)),
      build: buildBloc,
      act: (bloc) => bloc.add(const ToggleBiometrics()),
      expect: () => [
        const SettingsState(
          status: SettingsStatus.loaded,
          isBiometricsEnabled: true,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits error when toggle fails',
      setUp: () => when(() => repository.toggleBiometrics()).thenAnswer(
        (_) async => const Left(Failure.server(message: 'Toggle failed')),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const ToggleBiometrics()),
      expect: () => [
        const SettingsState(
          status: SettingsStatus.error,
          errorMessage: 'Toggle failed',
        ),
      ],
    );
  });

  group('ToggleNotifications', () {
    blocTest<SettingsBloc, SettingsState>(
      'toggles areNotificationsEnabled from true to false',
      build: buildBloc,
      act: (bloc) => bloc.add(const ToggleNotifications()),
      expect: () => [
        const SettingsState(areNotificationsEnabled: false),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<SettingsBloc, SettingsState>(
      'emits loggingOut then stays in loggingOut on success '
      '(router handles navigation)',
      setUp: () =>
          when(() => logoutDataSource.logout()).thenAnswer((_) async {}),
      build: buildBloc,
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const SettingsState(status: SettingsStatus.loggingOut),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits error when logout fails',
      setUp: () => when(() => logoutDataSource.logout())
          .thenThrow(Exception('Logout failed')),
      build: buildBloc,
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const SettingsState(status: SettingsStatus.loggingOut),
        const SettingsState(
          status: SettingsStatus.error,
          errorMessage: 'Exception: Logout failed',
        ),
      ],
    );
  });
}
