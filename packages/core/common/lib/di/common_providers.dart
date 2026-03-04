import 'package:common/config/environment.dart';
import 'package:common/network/dio_factory.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Shared Dio instance. Auto-configured from [environmentProvider].
final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(environmentProvider);
  final config = EnvironmentConfig.fromEnvironment(env);
  return DioFactory.create(
    environmentConfig: config,
    tokenProvider: () async => null,
    tokenRefresher: () async => null,
    onAuthFailure: () {},
  );
});
