import 'dart:convert';

import 'package:authentication/data/datasources/remote_auth_datasource.dart';
import 'package:authentication/data/models/auth_token_model.dart';
import 'package:authentication/data/models/login_response_model.dart';
import 'package:authentication/data/models/user_model.dart';
import 'package:flutter/services.dart';
import 'package:mock/config/mock_config.dart';
import 'package:mock/config/mock_delay.dart';

class MockAuthDataSource implements RemoteAuthDataSource {
  MockAuthDataSource({this.config = MockConfig.standard});
  final MockConfig config;

  @override
  Future<LoginResponseModel> login(String dni, String password) async {
    await MockDelay.simulate(config);

    final AuthTokenModel token;
    final UserModel user;

    if (dni == '12345678A' && password == 'Test1234!') {
      token = AuthTokenModel(
        accessToken:
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken:
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      final jsonString = await rootBundle.loadString(
        'packages/mock/assets/fixtures/user.json',
      );
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      user = UserModel.fromJson(jsonMap);
    } else if (dni == '87654321B' && password == 'Demo1234!') {
      token = AuthTokenModel(
        accessToken:
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken:
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      user = UserModel(
        id: 'usr-002',
        dni: dni,
        firstName: 'Demo',
        lastName: 'Usuario',
        email: 'demo@bankapp.com',
        createdAt: DateTime.utc(2024, 6),
      );
    } else {
      throw Exception('Credenciales inválidas');
    }

    return LoginResponseModel(token: token, user: user);
  }

  @override
  Future<void> logout(String token) async {
    await MockDelay.simulate(config);
  }
}
