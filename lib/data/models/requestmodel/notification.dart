class CreateNotificationRequest {
  final String userId;
  final String userModel;
  final String type;
  final String content;
  final String navigatePath;

  CreateNotificationRequest({
    required this.userId,
    required this.userModel,
    required this.type,
    required this.content,
    required this.navigatePath,
  });

  factory CreateNotificationRequest.fromJson(Map<String, dynamic> json) {
    return CreateNotificationRequest(
      userId: json['userId'],
      userModel: json['userModel'],
      type: json['type'],
      content: json['content'],
      navigatePath: json['navigatePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "userModel": userModel,
      "type": type,
      "content": content,
      "navigatePath": navigatePath,
    };
  }
}