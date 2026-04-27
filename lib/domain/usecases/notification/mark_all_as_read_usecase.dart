import '../../repositories/notification_repository.dart';

class MarkAllAsReadUseCase {
  final NotificationRepository repository;

  MarkAllAsReadUseCase(this.repository);

  Future<void> call(String userId) {
    return repository.markAllAsRead(userId);
  }
}
