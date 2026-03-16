import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';
import '../repositories/notification_repository.dart';

/// Marks a notification as read by its ID.
class MarkNotificationAsReadUseCase extends UseCase<void, String> {
  MarkNotificationAsReadUseCase({required this.repository});

  final NotificationRepository repository;

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.markAsRead(params);
  }
}
