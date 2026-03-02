import 'package:common/error/failures.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:payments/data/datasources/remote_payment_datasource.dart';
import 'package:payments/domain/entities/payment.dart';
import 'package:payments/domain/repositories/payment_repository.dart';

/// Concrete implementation of [PaymentRepository].
class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl({required this.remoteDataSource});

  final RemotePaymentDataSource remoteDataSource;

  @override
  Future<Either<Failure, String>> executePayment(Payment payment) async {
    try {
      final confirmationId = await remoteDataSource.executePayment(payment);
      return Right(confirmationId);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Error al ejecutar el pago',
          statusCode: e.response?.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
