import '../models/responsemodel/notification.dart';
import '../services/notification_service.dart';

class NotificationRepository{
  NotificationService service;
  NotificationRepository(this.service);

  Future<List<NotificationResponse>> getNotificationByUserId(String userId) async{
    return await service.getNotificationByUserId(userId);
  }

  Future<List<NotificationResponse>> getUnreadNotifications(String userId) async {
    return await service.getUnreadNotifications(userId);
  }

  Future<void> markAsRead(String notificationId) async {
    return await service.markAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    return await service.markAllAsRead(userId);
  }

  Future<void> deleteNotification(String notificationId) async {
    return await service.deleteNotification(notificationId);
  }

  // Future<NotificationResponse?> createNotification(
  //     String userId,
  //     String userModel,
  //     String type,
  //     String content,
  //     String navigatePath,
  //     ) async {
  //   return await service.createNotification(
  //     userId,
  //     userModel,
  //     type,
  //     content,
  //     navigatePath,
  //   );
  // }
}