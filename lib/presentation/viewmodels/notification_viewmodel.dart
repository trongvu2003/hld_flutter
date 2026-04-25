import 'package:flutter/cupertino.dart';
import '../../data/models/responsemodel/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository repository;

  NotificationViewModel(this.repository);

  List<NotificationResponse> notifications = [];
  int unreadCount = 0; // Thêm biến đếm số thông báo chưa đọc
  bool isLoading = false;
  bool isError = false;
  String error = '';

  //  Tự động đếm lại số lượng chưa đọc
  void _updateUnreadCount() {
    unreadCount = notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

  Future<void> fetchNotificationByUserId(String userId) async {
    isLoading = true;
    isError = false;
    error = '';
    notifyListeners();

    try {
      final res = await repository.getNotificationByUserId(userId);
      notifications = res;
      _updateUnreadCount();
    } catch (e) {
      error = e.toString();
      isError = true;
      print('LỖI FETCH NOTIFICATIONS: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // LẤY THÔNG BÁO CHƯA ĐỌC
  Future<void> fetchUnreadNotifications(String userId) async {
    isLoading = true;
    isError = false;
    error = '';
    notifyListeners();

    try {
      final res = await repository.getUnreadNotifications(userId);
      notifications = res;
      _updateUnreadCount();
    } catch (e) {
      error = e.toString();
      isError = true;
      print('LỖI FETCH UNREAD NOTIFICATIONS: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //  ĐÁNH DẤU 1 THÔNG BÁO LÀ ĐÃ ĐỌC
  Future<void> markAsRead(String notificationId) async {
    try {
      await repository.markAsRead(notificationId);

      // Cập nhật UI ngay lập tức trên RAM
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = NotificationResponse(
          id: notifications[index].id,
          user: notifications[index].user,
          type: notifications[index].type,
          content: notifications[index].content,
          navigatePath: notifications[index].navigatePath,
          isRead: true,
          // Đã đọc
          createdAt: notifications[index].createdAt,
        );
        _updateUnreadCount();
      }
    } catch (e) {
      print('LỖI MARK AS READ: $e');
    }
  }

  //  ĐÁNH DẤU TẤT CẢ LÀ ĐÃ ĐỌC
  Future<void> markAllAsRead(String userId) async {
    try {
      await repository.markAllAsRead(userId);

      // Map toàn bộ danh sách thành isRead = true
      notifications =
          notifications
              .map(
                (n) => NotificationResponse(
                  id: n.id,
                  user: n.user,
                  type: n.type,
                  content: n.content,
                  navigatePath: n.navigatePath,
                  isRead: true,
                  createdAt: n.createdAt,
                ),
              )
              .toList();

      _updateUnreadCount();
    } catch (e) {
      print('LỖI MARK ALL AS READ: $e');
    }
  }

  // XÓA THÔNG BÁO
  Future<void> deleteNotification(String notificationId) async {
    try {
      await repository.deleteNotification(notificationId);
      notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
    } catch (e) {
      print('LỖI DELETE NOTIFICATION: $e');
    }
  }

  Future<void> createNotification({
    required String userId,
    required String userModel,
    required String type,
    required String content,
    required String navigatePath,
  }) async {
    try {
      final newNotification = await repository.createNotification(
        userId,
        userModel,
        type,
        content,
        navigatePath,
      );

      if (newNotification != null) {
        notifications.insert(0, newNotification);
        _updateUnreadCount();
      }
    } catch (e) {
      print('LỖI CREATE NOTIFICATION: $e');
    }
  }
}
