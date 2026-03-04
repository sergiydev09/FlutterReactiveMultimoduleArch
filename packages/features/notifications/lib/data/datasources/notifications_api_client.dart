import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/notification_dto.dart';

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
