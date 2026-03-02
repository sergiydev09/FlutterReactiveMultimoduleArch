import 'package:equatable/equatable.dart';

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
class CardEntity extends Equatable {
  const CardEntity({
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

  /// Unique card identifier.
  final String id;

  /// Debit or credit.
  final CardType type;

  /// Last 4 digits of the card number.
  final String lastFourDigits;

  /// Name printed on the card.
  final String cardHolderName;

  /// Expiry date (MM/YY format string).
  final String expiryDate;

  /// Whether the card is currently active.
  final bool isActive;

  /// Card network brand.
  final CardBrand brand;

  /// Available credit limit (credit cards only).
  final double? availableLimit;

  /// Used portion of the credit limit (credit cards only).
  final double? usedLimit;

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

  /// Creates a copy with optionally overridden fields.
  CardEntity copyWith({
    String? id,
    CardType? type,
    String? lastFourDigits,
    String? cardHolderName,
    String? expiryDate,
    bool? isActive,
    CardBrand? brand,
    double? availableLimit,
    double? usedLimit,
  }) {
    return CardEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      brand: brand ?? this.brand,
      availableLimit: availableLimit ?? this.availableLimit,
      usedLimit: usedLimit ?? this.usedLimit,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    lastFourDigits,
    cardHolderName,
    expiryDate,
    isActive,
    brand,
    availableLimit,
    usedLimit,
  ];
}
