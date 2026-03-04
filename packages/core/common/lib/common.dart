/// Shared utilities, networking, config, and error handling.
library;

// Configuration
export 'config/environment.dart';
export 'di/common_providers.dart';
export 'error/failures.dart';
export 'extensions/either_extensions.dart';
export 'network/auth_interceptor.dart';
export 'network/cache_config.dart';
export 'network/dio_exception_mapper.dart';
export 'network/dio_factory.dart';
export 'network/logging_interceptor.dart';
export 'network/safe_api_call.dart';
export 'notifiers/environment_notifier.dart';
export 'routing/feature_routes.dart';
export 'usecases/usecase.dart';
export 'utils/formatters.dart';
