import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';
import '../extensions/either_extensions.dart';
import './dio_exception_mapper.dart';

/// Wraps an API call in a try/catch, mapping exceptions to [Failure].
Future<Either<Failure, T>> safeApiCall<T>(Future<T> Function() call) async {
  try {
    return (await call()).toRight();
  } on DioException catch (e) {
    return DioExceptionMapper.map(e).toLeft();
  } on Exception catch (e) {
    return ServerFailure(message: e.toString()).toLeft();
  }
}
