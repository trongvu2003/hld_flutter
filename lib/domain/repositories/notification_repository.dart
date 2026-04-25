import '../../data/models/responsemodel/notification.dart';

abstract class NotificationRepository {
  Future<List<NotificationResponse>> getNotificationByUserId(String userId);

  Future<List<NotificationResponse>> getUnreadNotifications(String userId);

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String userId);

  Future<void> deleteNotification(String notificationId);

  Future<NotificationResponse?> createNotification(
    String userId,
    String userModel,
    String type,
    String content,
    String navigatePath,
  );
}
