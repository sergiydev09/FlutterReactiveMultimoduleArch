import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/environment.dart';
import '../network/dio_factory.dart';
import '../notifiers/environment_notifier.dart';

/// Riverpod providers for the common/networking module.
abstract final class CommonProviders {
  /// Current app environment (mock / pre / pro).
  static final environment = NotifierProvider<EnvironmentNotifier, Environment>(
    EnvironmentNotifier.new,
  );

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
