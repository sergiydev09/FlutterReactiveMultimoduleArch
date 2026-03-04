import 'package:json_annotation/json_annotation.dart';

part 'generated/payment_response_dto.g.dart';

@JsonSerializable()
class PaymentResponseDto {
  const PaymentResponseDto({
    required this.confirmationId,
  });

  factory PaymentResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseDtoFromJson(json);

  @JsonKey(name: 'confirmation_id')
  final String confirmationId;

  Map<String, dynamic> toJson() => _$PaymentResponseDtoToJson(this);
}
