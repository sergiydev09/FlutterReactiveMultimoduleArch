import 'package:common/error/failures.dart';
import 'package:dio/dio.dart';

/// Maps a [DioException] to the appropriate [Failure] subtype.
abstract final class DioExceptionMapper {
  static Failure map(DioException e) => switch (e.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout =>
      NetworkFailure(message: e.message ?? 'Sin conexión a internet'),

    DioExceptionType.badResponse => switch (e.response?.statusCode) {
      401 => AuthFailure(
          message: e.message ?? 'No autorizado',
          statusCode: 401,
        ),
      _ => ServerFailure(
          message: e.message ?? 'Error del servidor',
          statusCode: e.response?.statusCode,
        ),
    },

    _ => ServerFailure(
        message: e.message ?? 'Error del servidor',
        statusCode: e.response?.statusCode,
      ),
  };
}
