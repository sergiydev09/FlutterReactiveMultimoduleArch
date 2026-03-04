import 'package:dio/dio.dart';
import 'package:notifications_feature/data/models/notification_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'generated/notifications_api_client.g.dart';

@RestApi()
abstract class NotificationsApiClient {
  factory NotificationsApiClient(Dio dio, {String? baseUrl}) =
      _NotificationsApiClient;

  @GET('/notifications')
  Future<List<NotificationDto>> getNotifications();

  @PATCH('/notifications/{id}/read')
  Future<void> markAsRead(@Path('id') String id);
}
