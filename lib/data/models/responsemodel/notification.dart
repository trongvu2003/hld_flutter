class NotificationResponse {
  final String id;
  final String user;
  final String type;
  final String content;
  final String navigatePath;
  final bool isRead;
  final String createdAt;

  NotificationResponse({
    required this.id,
    required this.user,
    required this.type,
    required this.content,
    required this.navigatePath,
    required this.isRead,
    required this.createdAt,
  });

  // Hàm chuyển đổi từ JSON (Map) sang Object
  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      id: json['_id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      navigatePath: json['navigatePath']?.toString() ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  // Hàm chuyển đổi từ Object sang JSON (nếu cần gửi lên server)
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Đẩy ngược lại thành '_id' cho backend hiểu
      'user': user,
      'type': type,
      'content': content,
      'navigatePath': navigatePath,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}
