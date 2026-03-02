import 'package:common/error/failures.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

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
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
