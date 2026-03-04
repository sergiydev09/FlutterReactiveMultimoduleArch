import 'package:domain/entities/card_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/card_dto.g.dart';

@JsonSerializable()
class CardDto {
  const CardDto({
    required this.id,
    required this.type,
    required this.lastFourDigits,
    required this.cardHolderName,
    required this.expiryDate,
    required this.brand,
    this.isActive = true,
    this.availableLimit,
    this.usedLimit,
  });

  factory CardDto.fromJson(Map<String, dynamic> json) =>
      _$CardDtoFromJson(json);

  final String id;
  final String type;
  @JsonKey(name: 'last_four_digits')
  final String lastFourDigits;
  @JsonKey(name: 'card_holder_name')
  final String cardHolderName;
  @JsonKey(name: 'expiry_date')
  final String expiryDate;
  final String brand;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'available_limit')
  final double? availableLimit;
  @JsonKey(name: 'used_limit')
  final double? usedLimit;

  Map<String, dynamic> toJson() => _$CardDtoToJson(this);

  CardEntity toEntity() {
    return CardEntity(
      id: id,
      type: _parseCardType(type),
      lastFourDigits: lastFourDigits,
      cardHolderName: cardHolderName,
      expiryDate: expiryDate,
      brand: _parseCardBrand(brand),
      isActive: isActive,
      availableLimit: availableLimit,
      usedLimit: usedLimit,
    );
  }

  static CardType _parseCardType(String type) {
    return switch (type.toLowerCase()) {
      'credit' => CardType.credit,
      _ => CardType.debit,
    };
  }

  static CardBrand _parseCardBrand(String brand) {
    return switch (brand.toLowerCase()) {
      'mastercard' => CardBrand.mastercard,
      _ => CardBrand.visa,
    };
  }
}
