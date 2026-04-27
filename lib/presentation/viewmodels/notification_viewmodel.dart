import 'package:flutter/cupertino.dart';
import '../../data/models/responsemodel/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/notification/create_notification_usecase.dart';
import '../../domain/usecases/notification/delete_notification_usecase.dart';
import '../../domain/usecases/notification/get_notifications_usecase.dart';
import '../../domain/usecases/notification/get_unread_notifications_usecase.dart';
import '../../domain/usecases/notification/mark_all_as_read_usecase.dart';
import '../../domain/usecases/notification/mark_as_read_usecase.dart';

class NotificationViewModel extends ChangeNotifier {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadNotificationsUseCase getUnreadNotificationsUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final MarkAllAsReadUseCase markAllAsReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;
  final CreateNotificationUseCase createNotificationUseCase;

  NotificationViewModel(
    this.getNotificationsUseCase,
    this.getUnreadNotificationsUseCase,
    this.markAsReadUseCase,
    this.markAllAsReadUseCase,
    this.deleteNotificationUseCase,
    this.createNotificationUseCase,
  );

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
      final res = await getNotificationsUseCase(userId);
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
      final res = await getUnreadNotificationsUseCase(userId);
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
      await markAsReadUseCase(notificationId);

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
      await markAllAsReadUseCase(userId);

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
      await deleteNotificationUseCase(notificationId);
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
      final newNotification = await createNotificationUseCase(
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
