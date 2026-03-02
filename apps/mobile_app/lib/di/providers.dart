import 'package:accounts/data/datasources/remote_account_datasource.dart';
import 'package:accounts/data/repositories/account_repository_impl.dart';
import 'package:accounts/domain/repositories/account_repository.dart';
import 'package:authentication/data/datasources/remote_auth_datasource.dart';
import 'package:authentication/data/repositories/auth_repository_impl.dart';
import 'package:authentication/domain/repositories/auth_repository.dart';
import 'package:cards/data/datasources/remote_card_datasource.dart';
import 'package:cards/data/repositories/card_repository_impl.dart';
import 'package:cards/domain/repositories/card_repository.dart';
import 'package:common/config/environment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globalposition/data/datasources/remote_globalposition_datasource.dart';
import 'package:globalposition/data/repositories/global_position_repository_impl.dart';
import 'package:globalposition/domain/repositories/global_position_repository.dart';
import 'package:notifications_feature/data/datasources/remote_notification_datasource.dart';
import 'package:notifications_feature/data/repositories/notification_repository_impl.dart';
import 'package:notifications_feature/domain/repositories/notification_repository.dart';
import 'package:payments/data/datasources/remote_payment_datasource.dart';
import 'package:payments/data/repositories/payment_repository_impl.dart';
import 'package:payments/domain/repositories/payment_repository.dart';
import 'package:promotions/data/promotions_datasource.dart';
import 'package:security/session/session_manager.dart';
import 'package:security/storage/secure_storage_service.dart';

// Environment
class EnvironmentNotifier extends Notifier<Environment> {
  @override
  Environment build() => Environment.mock;

  // Method used to update state from outside the notifier.
  // ignore: use_setters_to_change_properties
  void set(Environment value) => state = value;
}

final environmentProvider = NotifierProvider<EnvironmentNotifier, Environment>(
  EnvironmentNotifier.new,
);

// Security
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(secureStorage: ref.watch(secureStorageProvider));
});

// Auth
final remoteAuthDataSourceProvider = Provider<RemoteAuthDataSource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(remoteAuthDataSourceProvider),
  );
});

// Accounts
final remoteAccountDataSourceProvider = Provider<RemoteAccountDataSource>((
  ref,
) {
  throw UnimplementedError('Must be overridden');
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(
    remoteDataSource: ref.watch(remoteAccountDataSourceProvider),
  );
});

// Global Position
final remoteGlobalPositionDataSourceProvider =
    Provider<RemoteGlobalPositionDataSource>((ref) {
      throw UnimplementedError('Must be overridden');
    });

final globalPositionRepositoryProvider = Provider<GlobalPositionRepository>((
  ref,
) {
  return GlobalPositionRepositoryImpl(
    remoteDataSource: ref.watch(remoteGlobalPositionDataSourceProvider),
  );
});

// Payments
final remotePaymentDataSourceProvider = Provider<RemotePaymentDataSource>((
  ref,
) {
  throw UnimplementedError('Must be overridden');
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(
    remoteDataSource: ref.watch(remotePaymentDataSourceProvider),
  );
});

// Cards
final remoteCardDataSourceProvider = Provider<RemoteCardDataSource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepositoryImpl(
    remoteDataSource: ref.watch(remoteCardDataSourceProvider),
  );
});

// Notifications
final remoteNotificationDataSourceProvider =
    Provider<RemoteNotificationDataSource>((ref) {
      throw UnimplementedError('Must be overridden');
    });

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remoteDataSource: ref.watch(remoteNotificationDataSourceProvider),
  );
});

// Promotions
final remotePromotionsDataSourceProvider = Provider<RemotePromotionsDataSource>(
  (ref) {
    throw UnimplementedError('Must be overridden');
  },
);

// Auth state
class IsLoggedInNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  // Method used to update state from outside the notifier.
  // ignore: use_setters_to_change_properties
  void set({required bool value}) => state = value;
}

class CurrentUserNameNotifier extends Notifier<String> {
  @override
  String build() => '';

  // Method used to update state from outside the notifier.
  // ignore: use_setters_to_change_properties
  void set(String value) => state = value;
}

class HasSeenOnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  // Method used to update state from outside the notifier.
  // ignore: use_setters_to_change_properties
  void set({required bool value}) => state = value;
}

final isLoggedInProvider = NotifierProvider<IsLoggedInNotifier, bool>(
  IsLoggedInNotifier.new,
);
final currentUserNameProvider =
    NotifierProvider<CurrentUserNameNotifier, String>(
      CurrentUserNameNotifier.new,
    );
final hasSeenOnboardingProvider =
    NotifierProvider<HasSeenOnboardingNotifier, bool>(
      HasSeenOnboardingNotifier.new,
    );
