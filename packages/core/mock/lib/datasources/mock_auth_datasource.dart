import 'dart:convert';
import 'package:authentication/data/datasources/remote_auth_datasource.dart';
import 'package:authentication/data/models/auth_token_dto.dart';
import 'package:authentication/data/models/login_response_dto.dart';
import 'package:authentication/data/models/user_dto.dart';
import 'package:flutter/services.dart';
import '../config/mock_config.dart';
import '../config/mock_delay.dart';

class MockAuthDataSource implements RemoteAuthDataSource {
  MockAuthDataSource({this.config = MockConfig.standard});
  final MockConfig config;

  @override
  Future<LoginResponseDto> login(String dni, String password) async {
    await MockDelay.simulate(config);

    final AuthTokenDto token;
    final UserDto user;

    if (dni == '12345678A' && password == 'Test1234!') {
      token = AuthTokenDto(
        accessToken:
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken:
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt:
            DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      );
      final jsonString = await rootBundle.loadString(
        'packages/mock/assets/fixtures/user.json',
      );
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      user = UserDto.fromJson(jsonMap);
    } else if (dni == '87654321B' && password == 'Demo1234!') {
      token = AuthTokenDto(
        accessToken:
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken:
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt:
            DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      );
      user = UserDto(
        id: 'usr-002',
        dni: dni,
        firstName: 'Demo',
        lastName: 'Usuario',
        email: 'demo@bankapp.com',
        createdAt: DateTime.utc(2024, 6).toIso8601String(),
      );
    } else {
      throw Exception('Credenciales inválidas');
    }

    return LoginResponseDto(token: token, user: user);
  }

  @override
  Future<void> logout(String token) async {
    await MockDelay.simulate(config);
  }

  // ---------------------------------------------------------------------------
  // Biometric device credentials (stubs for dev)
  // ---------------------------------------------------------------------------

  @override
  Future<void> registerDevice({
    required String publicKey,
    required String deviceId,
  }) async {
    await MockDelay.simulate(config);
  }

  @override
  Future<String> getBiometricChallenge(String deviceId) async {
    await MockDelay.simulate(config);
    return 'mock_challenge_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<LoginResponseDto> verifyBiometric({
    required String signature,
    required String deviceId,
  }) async {
    await MockDelay.simulate(config);
    final token = AuthTokenDto(
      accessToken:
          'mock_bio_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_bio_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt:
          DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
    );
    final user = UserDto(
      id: 'usr-001',
      dni: '12345678A',
      firstName: 'Juan',
      lastName: 'García',
      email: 'juan@bankapp.com',
      createdAt: DateTime.utc(2024).toIso8601String(),
    );
    return LoginResponseDto(token: token, user: user);
  }

  @override
  Future<void> unregisterDevice(String deviceId) async {
    await MockDelay.simulate(config);
  }
}
