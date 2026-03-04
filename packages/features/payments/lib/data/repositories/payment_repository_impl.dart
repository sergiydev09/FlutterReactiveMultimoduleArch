import 'package:common/error/failures.dart';
import 'package:common/network/safe_api_call.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/remote_payment_datasource.dart';
import '../models/payment_request_dto.dart';

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
