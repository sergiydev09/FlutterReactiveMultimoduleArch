import 'package:common/usecases/usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:security/security.dart';

class MockLogoutDataSource extends Mock implements LogoutDataSource {}

void main() {
  late MockLogoutDataSource logoutDataSource;
  late LogoutUseCase useCase;

  setUp(() {
    logoutDataSource = MockLogoutDataSource();
    useCase = LogoutUseCase(logoutDataSource: logoutDataSource);
  });

  group('LogoutUseCase', () {
    test('returns Right(null) when datasource succeeds', () async {
      when(() => logoutDataSource.logout()).thenAnswer((_) async {});

      final result = await useCase(const NoParams());

      expect(result.isRight(), isTrue);
      verify(() => logoutDataSource.logout()).called(1);
    });

    test('returns Left(ServerFailure) when datasource throws', () async {
      when(() => logoutDataSource.logout())
          .thenThrow(Exception('Storage error'));

      final result = await useCase(const NoParams());

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('Storage error')),
        (_) => fail('Expected Left'),
      );
    });
  });
}
