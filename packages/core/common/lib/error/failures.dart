import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/failures.freezed.dart';

/// Base failure class for the application.
///
/// All specific failure types extend this sealed class,
/// ensuring exhaustive pattern matching in error handling.
@freezed
sealed class Failure with _$Failure {
  /// Failure originating from a remote server response.
  const factory Failure.server({
    @Default('Server error') String message,
    int? statusCode,
  }) = ServerFailure;

  /// Failure originating from local cache operations.
  const factory Failure.cache({
    @Default('Cache error') String message,
    int? statusCode,
  }) = CacheFailure;

  /// Failure related to authentication or authorization.
  const factory Failure.auth({
    @Default('Authentication error') String message,
    int? statusCode,
  }) = AuthFailure;

  /// Failure due to network connectivity issues.
  const factory Failure.network({
    @Default('No internet connection') String message,
    int? statusCode,
  }) = NetworkFailure;
}
