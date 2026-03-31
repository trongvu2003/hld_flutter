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

class PostResponse {
  final String id;
  final String content;
  final List<String> media;
  final UserInfo? userInfo;
  final String userModel;
  final String createdAt;

  PostResponse({
    required this.id,
    required this.content,
    required this.media,
    this.userInfo,
    required this.userModel,
    required this.createdAt,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
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
  final List<PostResponse> posts;
  final bool hasMore;

  PostPageResponse({required this.posts, required this.hasMore});

  factory PostPageResponse.fromJson(Map<String, dynamic> json) {
    return PostPageResponse(
      posts: (json['posts'] as List).map((i) => PostResponse.fromJson(i)).toList(),
      hasMore: json['hasMore'] ?? false,
    );
  }
}

class CreatePostResponse {
  final String user;
  final String content;
  final List<String> media;
  final String keywords;

  CreatePostResponse({
    required this.user,
    required this.content,
    required this.media,
    required this.keywords,
  });

  factory CreatePostResponse.fromJson(Map<String, dynamic> json) {
    return CreatePostResponse(
      user: json['user'] ?? '',
      content: json['content'] ?? '',
      media: List<String>.from(json['media'] ?? []),
      keywords: json['keywords'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'content': content,
      'media': media,
      'keywords': keywords,
    };
  }
}
