class UserInfo {
  final String id;
  final String name;
  final String? avatarUrl;

  UserInfo({required this.id, required this.name, this.avatarUrl});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarURL'],
    );
  }
}

class PostModel {
  final String id;
  final String content;
  final List<String> media;
  final UserInfo? userInfo;
  final String userModel;
  final String createdAt;

  PostModel({
    required this.id,
    required this.content,
    required this.media,
    this.userInfo,
    required this.userModel,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      media: List<String>.from(json['media'] ?? []),
      userInfo: json['userInfo'] != null ? UserInfo.fromJson(json['userInfo']) : null,
      userModel: json['userModel'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class PostPageResponse {
  final List<PostModel> posts;
  final bool hasMore;

  PostPageResponse({required this.posts, required this.hasMore});

  factory PostPageResponse.fromJson(Map<String, dynamic> json) {
    return PostPageResponse(
      posts: (json['posts'] as List).map((i) => PostModel.fromJson(i)).toList(),
      hasMore: json['hasMore'] ?? false,
    );
  }
}