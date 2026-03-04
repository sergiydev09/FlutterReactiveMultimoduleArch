import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/login_response_dto.dart';

part 'generated/auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String? baseUrl}) = _AuthApiClient;

  @POST('/auth/login')
  Future<LoginResponseDto> login(@Body() Map<String, dynamic> credentials);

  @POST('/auth/logout')
  Future<void> logout(@Header('Authorization') String token);
}
