import '../../repositories/notification_repository.dart';

class MarkAsReadUseCase {
  final NotificationRepository repository;

  MarkAsReadUseCase(this.repository);

  Future<void> call(String notificationId) {
    return repository.markAsRead(notificationId);
  }
}
