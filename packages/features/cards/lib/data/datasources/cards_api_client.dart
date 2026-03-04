import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/card_dto.dart';

part 'generated/cards_api_client.g.dart';

@RestApi()
abstract class CardsApiClient {
  factory CardsApiClient(Dio dio, {String? baseUrl}) = _CardsApiClient;

  @GET('/cards')
  Future<List<CardDto>> getCards();

  @GET('/cards/{id}')
  Future<CardDto> getCardDetail(@Path('id') String id);

  @PATCH('/cards/{id}/toggle-status')
  Future<CardDto> toggleCardStatus(@Path('id') String id);
}
