import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/card_entity.freezed.dart';

/// Card type (debit or credit).
enum CardType {
  /// Debit card linked to a current account.
  debit,

  /// Credit card with a credit limit.
  credit,
}

/// Card brand / network.
enum CardBrand {
  /// Visa.
  visa,

  /// Mastercard.
  mastercard,
}

/// Represents a bank card (debit or credit).
@freezed
abstract class CardEntity with _$CardEntity {
  const factory CardEntity({
    required String id,
    required CardType type,
    required String lastFourDigits,
    required String cardHolderName,
    required String expiryDate,
    required CardBrand brand,
    @Default(true) bool isActive,
    double? availableLimit,
    double? usedLimit,
  }) = _CardEntity;

  const CardEntity._();

  /// Whether this is a credit card.
  bool get isCredit => type == CardType.credit;

  /// Whether this is a debit card.
  bool get isDebit => type == CardType.debit;

  /// Masked card number for display (e.g. "**** **** **** 1234").
  String get maskedNumber => '**** **** **** $lastFourDigits';

  /// Credit usage percentage (0.0 to 1.0). Returns null for debit cards.
  double? get usagePercentage {
    if (availableLimit == null || usedLimit == null || availableLimit == 0) {
      return null;
    }
    return usedLimit! / (availableLimit! + usedLimit!);
  }
}
