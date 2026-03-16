import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/notification_entity.dart';
import 'package:fpdart/fpdart.dart';
import '../repositories/notification_repository.dart';

/// Fetches all notifications for the current user.
class GetNotificationsUseCase
    extends UseCase<List<NotificationEntity>, NoParams> {
  GetNotificationsUseCase({required this.repository});

  final NotificationRepository repository;

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(NoParams params) {
    return repository.getNotifications();
  }
}
