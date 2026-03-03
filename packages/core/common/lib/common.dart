/// Shared utilities, networking, config, and error handling.
library;

// Configuration
export 'config/environment.dart';
// DI
export 'di/common_providers.dart';
// Error handling
export 'error/failures.dart';
// Extensions
export 'extensions/either_extensions.dart';
// Network
export 'network/auth_interceptor.dart';
export 'network/cache_config.dart';
export 'network/dio_factory.dart';
export 'network/logging_interceptor.dart';
// Routing
export 'routing/feature_routes.dart';
// Use cases
export 'usecases/usecase.dart';
// Utilities
export 'utils/formatters.dart';
