import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:globalposition/data/datasources/remote_globalposition_datasource.dart';
import 'package:globalposition/data/models/gp_account_dto.dart';
import 'package:globalposition/data/models/gp_transaction_dto.dart';
import '../config/mock_config.dart';
import '../config/mock_delay.dart';

class MockGlobalPositionDataSource implements RemoteGlobalPositionDataSource {
  MockGlobalPositionDataSource({this.config = MockConfig.standard});
  final MockConfig config;

  @override
  Future<List<GpAccountDto>> getAccounts() async {
    await MockDelay.simulate(config);
    final jsonString = await rootBundle.loadString(
      'packages/mock/assets/fixtures/accounts.json',
    );
    final list = json.decode(jsonString) as List<dynamic>;
    return list
        .map((e) => GpAccountDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<GpTransactionDto>> getRecentTransactions() async {
    await MockDelay.simulate(config);
    final jsonString = await rootBundle.loadString(
      'packages/mock/assets/fixtures/transactions.json',
    );
    final list = json.decode(jsonString) as List<dynamic>;
    return list
        .take(5)
        .map((e) => GpTransactionDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
