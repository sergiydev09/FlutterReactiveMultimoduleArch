import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../error/failures.dart';

part 'generated/usecase.freezed.dart';

/// Abstract use case contract.
///
/// Every use case in the application must implement this interface.
/// [T] is the return type on success.
/// [Params] is the parameter object required to execute the use case.
abstract class UseCase<T, Params> {
  /// Executes the use case with the given [params].
  ///
  /// Returns an [Either] containing a [Failure] on the left side
  /// or the successful result of type [T] on the right side.
  Future<Either<Failure, T>> call(Params params);
}

/// Use this when a use case does not require any parameters.
@freezed
abstract class NoParams with _$NoParams {
  const factory NoParams() = _NoParams;
}
