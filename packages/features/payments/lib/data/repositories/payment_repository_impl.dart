import 'package:common/error/failures.dart';
import 'package:common/network/safe_api_call.dart';
import 'package:fpdart/fpdart.dart';
import 'package:payments/data/datasources/remote_payment_datasource.dart';
import 'package:payments/data/models/payment_request_dto.dart';
import 'package:payments/domain/entities/payment.dart';
import 'package:payments/domain/repositories/payment_repository.dart';

/// Concrete implementation of [PaymentRepository].
class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl({required this.remoteDataSource});

  final RemotePaymentDataSource remoteDataSource;

  @override
  Future<Either<Failure, String>> executePayment(Payment payment) =>
      safeApiCall(() async {
        final request = PaymentRequestDto.fromEntity(payment);
        final response = await remoteDataSource.executePayment(request);
        return response.confirmationId;
      });
}
