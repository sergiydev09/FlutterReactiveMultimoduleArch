import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:security/security.dart';

class MockSessionManager extends Mock implements SessionManager {}

class MockUserSessionNotifier extends Mock implements UserSessionNotifier {}

void main() {
  late MockSessionManager sessionManager;
  late MockUserSessionNotifier userSessionNotifier;
  late LogoutDataSourceImpl datasource;

  setUp(() {
    sessionManager = MockSessionManager();
    userSessionNotifier = MockUserSessionNotifier();
    datasource = LogoutDataSourceImpl(
      sessionManager: sessionManager,
      userSessionNotifier: userSessionNotifier,
    );
  });

  group('LogoutDataSourceImpl', () {
    test('calls clearSession on the session manager', () async {
      when(() => sessionManager.clearSession()).thenAnswer((_) async {});

      await datasource.logout();

      verify(() => sessionManager.clearSession()).called(1);
    });

    test('calls clear on the user session notifier', () async {
      when(() => sessionManager.clearSession()).thenAnswer((_) async {});

      await datasource.logout();

      verify(() => userSessionNotifier.clear()).called(1);
    });

    test('clears session before clearing user notifier', () async {
      final callOrder = <String>[];

      when(() => sessionManager.clearSession()).thenAnswer((_) async {
        callOrder.add('clearSession');
      });
      when(() => userSessionNotifier.clear()).thenAnswer((_) {
        callOrder.add('clear');
      });

      await datasource.logout();

      expect(callOrder, ['clearSession', 'clear']);
    });
  });
}
