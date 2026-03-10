import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/biometric_challenge_dto.dart';
import '../models/login_response_dto.dart';

part 'generated/auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String? baseUrl}) = _AuthApiClient;

  @POST('/auth/login')
  Future<LoginResponseDto> login(@Body() Map<String, dynamic> credentials);

  @POST('/auth/logout')
  Future<void> logout(@Header('Authorization') String token);

  // ---------------------------------------------------------------------------
  // Biometric device credentials
  // ---------------------------------------------------------------------------

  @POST('/auth/biometric/register')
  Future<void> registerDevice(@Body() Map<String, dynamic> body);

  @POST('/auth/biometric/challenge')
  Future<BiometricChallengeDto> getBiometricChallenge(
    @Query('deviceId') String deviceId,
  );

  @POST('/auth/biometric/verify')
  Future<LoginResponseDto> verifyBiometric(@Body() Map<String, dynamic> body);

  @DELETE('/auth/biometric/device/{deviceId}')
  Future<void> unregisterDevice(@Path('deviceId') String deviceId);
}
