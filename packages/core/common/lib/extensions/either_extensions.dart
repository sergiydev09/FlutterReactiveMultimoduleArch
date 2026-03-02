import 'package:common/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Convenience extensions on [Either<Failure, T>].
extension EitherExtensions<T> on Either<Failure, T> {
  /// Returns the right value or throws a [StateError] if left.
  T getOrThrow() => match(
    (failure) => throw StateError(
      'Expected Right but got Left: ${failure.message}',
    ),
    (value) => value,
  );

  /// Returns the right value or [defaultValue] if left.
  T getOrElse(T defaultValue) => match(
    (_) => defaultValue,
    (value) => value,
  );

  /// Returns the failure or `null` if right.
  Failure? get failureOrNull => match(
    (failure) => failure,
    (_) => null,
  );

  /// Returns `true` if this is a successful result.
  bool get isSuccess => isRight();

  /// Returns `true` if this is a failure result.
  bool get isFailure => isLeft();

  /// Applies [onSuccess] if right, [onFailure] if left.
  void when({
    required void Function(Failure failure) onFailure,
    required void Function(T value) onSuccess,
  }) {
    match(
      onFailure,
      onSuccess,
    );
  }
}
