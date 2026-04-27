import '../../repositories/notification_repository.dart';
import '../../../data/models/responsemodel/notification.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationResponse>> call(String userId) {
    return repository.getNotificationByUserId(userId);
  }
}
