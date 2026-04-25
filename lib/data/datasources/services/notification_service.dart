import 'package:dio/dio.dart';
import '../../models/requestmodel/notification.dart';
import '../../models/responsemodel/notification.dart';


class NotificationService {
  final Dio dio;
  NotificationService(this.dio);

  Future<List<NotificationResponse>> getNotificationByUserId(
    String userId,
  ) async {
    try {
      final res = await dio.get('/notification/get-by-user-id/$userId');
      if (res.statusCode == 200) {
        List<dynamic> data = res.data;
        return data
            .map((dynamic item) => NotificationResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Lỗi API: Server trả về mã ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('lỗi k xác định:' + e.toString());
    }
  }

  Future<List<NotificationResponse>> getUnreadNotifications(
    String userId,
  ) async {
    try {
      final res = await dio.get('/notification/get-by-user-id/$userId/unread');
      if (res.statusCode == 200) {
        return (res.data as List)
            .map((dynamic item) => NotificationResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Lỗi API: Server trả về mã ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Lấy số lượng thông báo chưa đọc
  Future<int> getUnreadCount(String userId) async {
    try {
      final res = await dio.get(
        '/notification/get-by-user-id/$userId/unread-count',
      );
      if (res.statusCode == 200) {
        return int.tryParse(res.data.toString()) ?? 0;
      }
      return 0;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<NotificationResponse?> createNotification(
    String userId,
    String userModel,
    String type,
    String content,
    String navigatePath,
  ) async {
    try {
      final request = CreateNotificationRequest(
        userId: userId,
        userModel: userModel,
        type: type,
        content: content,
        navigatePath: navigatePath,
      );

      final res = await dio.post(
        '/notification/create',
        data: request.toJson(),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return NotificationResponse.fromJson(res.data);
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Đánh dấu 1 thông báo là đã đọc
  Future<void> markAsRead(String notificationId) async {
    try {
      final res = await dio.patch('/notification/$notificationId/mark-as-read');
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Lỗi API: Server trả về mã ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  //Đánh dấu tất cả thông báo là đã đọc
  Future<void> markAllAsRead(String userId) async {
    try {
      final res = await dio.patch(
        '/notification/get-by-user-id/$userId/mark-all-as-read',
      );
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Lỗi API: Server trả về mã ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // DELETE: Xóa thông báo
  Future<void> deleteNotification(String notificationId) async {
    try {
      final res = await dio.delete('/notification/$notificationId/delete');
      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Lỗi API: Server trả về mã ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
