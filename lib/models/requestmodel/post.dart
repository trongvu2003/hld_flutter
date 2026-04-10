class CreatePostRequest {
  final String userId;
  final String userModel;
  final String content;
  final List<String> mediaPaths;

  CreatePostRequest({
    required this.userId,
    required this.userModel,
    required this.content,
    required this.mediaPaths,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "userModel": userModel,
      "content": content,
      "media": mediaPaths,
    };
  }
}


class CreateCommentPostRequest {
  final String userId;
  final String userModel;
  final String content;

  CreateCommentPostRequest({
    required this.userId,
    required this.userModel,
    required this.content,
  });

  factory CreateCommentPostRequest.fromJson(Map<String, dynamic> json) {
    return CreateCommentPostRequest(
      userId: json['userId'] ?? '',
      userModel: json['userModel'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userModel': userModel,
      'content': content,
    };
  }
}