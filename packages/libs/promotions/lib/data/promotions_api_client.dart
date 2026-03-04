import 'package:dio/dio.dart';
import 'package:promotions/data/models/promo_banner_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'generated/promotions_api_client.g.dart';

@RestApi()
abstract class PromotionsApiClient {
  factory PromotionsApiClient(Dio dio, {String? baseUrl}) =
      _PromotionsApiClient;

  @GET('/promotions')
  Future<List<PromoBannerDto>> fetchPromotions();
}
