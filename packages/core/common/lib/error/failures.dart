import 'package:equatable/equatable.dart';

/// Base failure class for the application.
///
/// All specific failure types extend this sealed class,
/// ensuring exhaustive pattern matching in error handling.
sealed class Failure extends Equatable {
  const Failure({this.message = '', this.statusCode});

  /// Human-readable error message.
  final String message;

  /// Optional HTTP status code associated with the failure.
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure originating from a remote server response.
final class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error', super.statusCode});
}

/// Failure originating from local cache operations.
final class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error'});
}

/// Failure related to authentication or authorization.
final class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication error', super.statusCode});
}

/// Failure due to network connectivity issues.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}
