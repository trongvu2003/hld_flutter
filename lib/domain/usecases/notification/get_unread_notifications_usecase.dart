import '../../../data/models/responsemodel/notification.dart';
import '../../repositories/notification_repository.dart';

class GetUnreadNotificationsUseCase {
  final NotificationRepository repository;

  GetUnreadNotificationsUseCase(this.repository);

  Future<List<NotificationResponse>> call(String userId) {
    return repository.getUnreadNotifications(userId);
  }
}
