import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment.dart';

part 'generated/payment_request_dto.g.dart';

@JsonSerializable()
class PaymentRequestDto {
  const PaymentRequestDto({
    required this.fromAccount,
    required this.toIban,
    required this.amount,
    required this.concept,
  });

  factory PaymentRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestDtoFromJson(json);

  factory PaymentRequestDto.fromEntity(Payment payment) {
    return PaymentRequestDto(
      fromAccount: payment.fromAccount,
      toIban: payment.toIban,
      amount: payment.amount,
      concept: payment.concept,
    );
  }

  @JsonKey(name: 'from_account')
  final String fromAccount;
  @JsonKey(name: 'to_iban')
  final String toIban;
  final double amount;
  final String concept;

  Map<String, dynamic> toJson() => _$PaymentRequestDtoToJson(this);
}
