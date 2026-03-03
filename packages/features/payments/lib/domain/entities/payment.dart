import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/payment.freezed.dart';

@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required String fromAccount,
    required String toIban,
    required double amount,
    required String concept,
  }) = _Payment;
}
