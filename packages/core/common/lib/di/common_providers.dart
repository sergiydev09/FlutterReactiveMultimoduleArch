import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/environment.dart';
import '../localization/locale_change_notifier.dart';
import '../network/dio_factory.dart';
import '../notifiers/environment_notifier.dart';

/// Riverpod providers for the common/networking module.
abstract final class CommonProviders {
  /// Current app environment (mock / pre / pro).
  static final environment = NotifierProvider<EnvironmentNotifier, Environment>(
    EnvironmentNotifier.new,
  );

  /// Trigger a full-app locale rebuild by calling
  /// `ref.read(CommonProviders.localeChangeNotifier.notifier).rebuild()`.
  /// Watching this in [routerProvider] causes a new [GoRouter] to be created,
  /// which forces [BankingApp] to rebuild the entire widget tree.
  static final localeChangeNotifier =
      NotifierProvider<LocaleChangeNotifier, int>(LocaleChangeNotifier.new);

  /// Shared Dio instance. Auto-configured from [environment].
  static final dio = Provider<Dio>((ref) {
    final env = ref.watch(CommonProviders.environment);
    final config = EnvironmentConfig.fromEnvironment(env);
    return DioFactory.create(
      environmentConfig: config,
      tokenProvider: () async => null,
      tokenRefresher: () async => null,
      onAuthFailure: () {},
    );
  });
}
