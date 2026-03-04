import 'dart:convert';
import 'package:cards/data/datasources/remote_card_datasource.dart';
import 'package:cards/data/models/card_dto.dart';
import 'package:flutter/services.dart';
import '../config/mock_config.dart';
import '../config/mock_delay.dart';

class MockCardDataSource implements RemoteCardDataSource {
  MockCardDataSource({this.config = MockConfig.standard});
  final MockConfig config;
  final Map<String, bool> _cardStatusOverrides = {};

  @override
  Future<List<CardDto>> getCards() async {
    await MockDelay.simulate(config);
    final jsonString = await rootBundle.loadString(
      'packages/mock/assets/fixtures/cards.json',
    );
    final list = json.decode(jsonString) as List<dynamic>;
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      final id = map['id'] as String;
      final isActive =
          _cardStatusOverrides[id] ?? (map['is_active'] as bool? ?? true);
      return CardDto(
        id: id,
        type: map['type'] as String,
        lastFourDigits: map['last_four_digits'] as String,
        cardHolderName: map['card_holder_name'] as String,
        expiryDate: map['expiry_date'] as String,
        isActive: isActive,
        brand: map['brand'] as String,
        availableLimit: (map['available_limit'] as num?)?.toDouble(),
        usedLimit: (map['used_limit'] as num?)?.toDouble(),
      );
    }).toList();
  }

  @override
  Future<CardDto> getCardDetail(String id) async {
    final cards = await getCards();
    return cards.firstWhere((c) => c.id == id);
  }

  @override
  Future<CardDto> toggleCardStatus(String id) async {
    await MockDelay.simulate(config);
    final card = await getCardDetail(id);
    _cardStatusOverrides[id] = !card.isActive;
    return CardDto(
      id: card.id,
      type: card.type,
      lastFourDigits: card.lastFourDigits,
      cardHolderName: card.cardHolderName,
      expiryDate: card.expiryDate,
      isActive: !card.isActive,
      brand: card.brand,
      availableLimit: card.availableLimit,
      usedLimit: card.usedLimit,
    );
  }
}
