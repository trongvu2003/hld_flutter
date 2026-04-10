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
      userInfo:
          json['userInfo'] != null ? UserInfo.fromJson(json['userInfo']) : null,
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
      posts:
          (json['posts'] as List).map((i) => PostResponse.fromJson(i)).toList(),
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

class CommentUser {
  final String id;
  final String name;
  final String? avatarURL;

  const CommentUser({required this.id, required this.name, this.avatarURL});

  // Chuyển đổi từ JSON sang Object
  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      avatarURL: json['avatarURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'avatarURL': avatarURL};
  }
}

class CommentPostResponse {
  final String id;
  final CommentUser user;
  final String post;
  final String content;
  final String createdAt;

  const CommentPostResponse({
    required this.id,
    required this.user,
    required this.post,
    required this.content,
    required this.createdAt,
  });

  factory CommentPostResponse.fromJson(Map<String, dynamic> json) {
    return CommentPostResponse(
      id: json['_id'] ?? '',
      // Map key '_id'
      user: CommentUser.fromJson(json['user'] ?? {}),
      post: json['post'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'post': post,
      'content': content,
      'createdAt': createdAt,
    };
  }
}

class GetCommentPageResponse {
  final List<CommentPostResponse> comments;
  final bool hasMore;

  const GetCommentPageResponse({required this.comments, required this.hasMore});

  factory GetCommentPageResponse.fromJson(Map<String, dynamic> json) {
    var commentsList = json['comments'] as List? ?? [];

    return GetCommentPageResponse(
      comments:
          commentsList
              .map((item) => CommentPostResponse.fromJson(item))
              .toList(),
      hasMore: json['hasMore'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comments': comments.map((e) => e.toJson()).toList(),
      'hasMore': hasMore,
    };
  }
}
