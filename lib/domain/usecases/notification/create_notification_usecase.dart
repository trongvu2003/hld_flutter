import '../../../data/models/responsemodel/notification.dart';
import '../../repositories/notification_repository.dart';

class CreateNotificationUseCase {
  final NotificationRepository repository;

  CreateNotificationUseCase(this.repository);

  Future<NotificationResponse?> call(
    String userId,
    String userModel,
    String type,
    String content,
    String navigatePath,
  ) {
    return repository.createNotification(
      userId,
      userModel,
      type,
      content,
      navigatePath,
    );
  }
}
