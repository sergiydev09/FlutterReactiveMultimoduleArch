import 'dart:convert';

import 'package:accounts/data/datasources/remote_account_datasource.dart';
import 'package:accounts/data/models/account_model.dart';
import 'package:accounts/data/models/transaction_model.dart';
import 'package:flutter/services.dart';
import 'package:mock/config/mock_config.dart';
import 'package:mock/config/mock_delay.dart';

class MockAccountDataSource implements RemoteAccountDataSource {
  MockAccountDataSource({this.config = MockConfig.standard});
  final MockConfig config;

  @override
  Future<List<AccountModel>> getAccounts() async {
    await MockDelay.simulate(config);
    final jsonString = await rootBundle.loadString(
      'packages/mock/assets/fixtures/accounts.json',
    );
    final list = json.decode(jsonString) as List<dynamic>;
    return list
        .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AccountModel> getAccountDetail(String id) async {
    await MockDelay.simulate(config);
    final jsonString = await rootBundle.loadString(
      'packages/mock/assets/fixtures/accounts.json',
    );
    final list = json.decode(jsonString) as List<dynamic>;
    final accounts = list
        .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return accounts.firstWhere((a) => a.id == id);
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    required String accountId,
    DateTime? from,
    DateTime? to,
    int page = 0,
    int pageSize = 20,
  }) async {
    await MockDelay.simulate(config);
    final jsonString = await rootBundle.loadString(
      'packages/mock/assets/fixtures/transactions.json',
    );
    final list = json.decode(jsonString) as List<dynamic>;
    final allTransactions = list
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .where((t) => t.accountId == accountId)
        .toList();

    final start = page * pageSize;
    if (start >= allTransactions.length) return [];
    final end = (start + pageSize).clamp(0, allTransactions.length);
    return allTransactions.sublist(start, end);
  }
}
