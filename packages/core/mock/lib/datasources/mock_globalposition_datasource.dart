import 'dart:convert';

import 'package:domain/entities/account.dart';
import 'package:domain/entities/transaction.dart';
import 'package:flutter/services.dart';
import 'package:globalposition/data/datasources/remote_globalposition_datasource.dart';
import 'package:mock/config/mock_config.dart';
import 'package:mock/config/mock_delay.dart';

class MockGlobalPositionDataSource implements RemoteGlobalPositionDataSource {
  MockGlobalPositionDataSource({this.config = MockConfig.standard});
  final MockConfig config;

  @override
  Future<List<Account>> getAccounts() async {
    await MockDelay.simulate(config);
    final jsonString = await rootBundle.loadString(
      'packages/mock/assets/fixtures/accounts.json',
    );
    final list = json.decode(jsonString) as List<dynamic>;
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return Account(
        id: map['id'] as String,
        type: _parseAccountType(map['type'] as String),
        name: map['name'] as String,
        iban: map['iban'] as String,
        balance: (map['balance'] as num).toDouble(),
        currency: map['currency'] as String? ?? 'EUR',
        isMain: map['is_main'] as bool? ?? false,
      );
    }).toList();
  }

  @override
  Future<List<Transaction>> getRecentTransactions() async {
    await MockDelay.simulate(config);
    final jsonString = await rootBundle.loadString(
      'packages/mock/assets/fixtures/transactions.json',
    );
    final list = json.decode(jsonString) as List<dynamic>;
    return list.take(5).map((e) {
      final map = e as Map<String, dynamic>;
      final merchantData = map['merchant'];
      String? merchantName;
      if (merchantData is Map<String, dynamic>) {
        merchantName = merchantData['name'] as String?;
      }
      return Transaction(
        id: map['id'] as String,
        accountId: map['account_id'] as String,
        amount: (map['amount'] as num).toDouble(),
        currency: map['currency'] as String? ?? 'EUR',
        description: map['description'] as String,
        category: TransactionCategory.other,
        status: TransactionStatus.completed,
        createdAt: DateTime.parse(map['created_at'] as String),
        merchant: merchantName,
      );
    }).toList();
  }

  static AccountType _parseAccountType(String type) {
    return switch (type.toLowerCase()) {
      'current' || 'checking' => AccountType.current,
      'savings' => AccountType.savings,
      'investment' => AccountType.investment,
      _ => AccountType.current,
    };
  }
}
