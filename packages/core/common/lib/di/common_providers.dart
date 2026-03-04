import 'package:common/config/environment.dart';
import 'package:common/network/dio_factory.dart';
import 'package:common/notifiers/environment_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
