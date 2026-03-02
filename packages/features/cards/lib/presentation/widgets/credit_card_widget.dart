import 'package:domain/entities/card_entity.dart';
import 'package:flutter/material.dart';

/// A visual credit/debit card widget with gradient background.
class CreditCardWidget extends StatelessWidget {
  const CreditCardWidget({
    required this.card,
    super.key,
    this.onTap,
  });

  /// The card entity to display.
  final CardEntity card;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: _gradientColors.first.withValues(alpha:0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles.
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha:0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha:0.08),
                ),
              ),
            ),
            // Card content.
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand and type.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _brandLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: card.isActive
                              ? Colors.white.withValues(alpha:0.2)
                              : Colors.red.withValues(alpha:0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          card.isActive ? _typeLabel : 'Bloqueada',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Chip icon.
                  Container(
                    width: 40,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Card number.
                  Text(
                    card.maskedNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Holder and expiry.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TITULAR',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.6),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card.cardHolderName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'VÁLIDA',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.6),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card.expiryDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> get _gradientColors {
    if (!card.isActive) {
      return [Colors.grey.shade600, Colors.grey.shade800];
    }
    return switch (card.brand) {
      CardBrand.visa => [
        const Color(0xFF1A237E),
        const Color(0xFF0D47A1),
      ],
      CardBrand.mastercard => [
        const Color(0xFF1B5E20),
        const Color(0xFF2E7D32),
      ],
    };
  }

  String get _brandLabel {
    return switch (card.brand) {
      CardBrand.visa => 'VISA',
      CardBrand.mastercard => 'MASTERCARD',
    };
  }

  String get _typeLabel {
    return switch (card.type) {
      CardType.debit => 'Débito',
      CardType.credit => 'Crédito',
    };
  }
}
