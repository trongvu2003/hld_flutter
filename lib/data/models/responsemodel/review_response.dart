class ReviewResponse {
  final String? id;
  final int? rating;
  final String? comment;
  final String? createdAt;
  final ReviewUser? user;

  ReviewResponse({
    this.id,
    this.rating,
    this.comment,
    this.createdAt,
    this.user,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: json['_id']?.toString(),
      rating:
          json['rating'] is int
              ? json['rating']
              : int.tryParse(json['rating']?.toString() ?? ''),
      comment: json['comment']?.toString(),
      createdAt: json['createdAt']?.toString(),
      user: json['user'] != null ? ReviewUser.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'user': user?.toJson(),
    };
  }
}

class ReviewUser {
  final String? id;
  final String? name;
  final String? userImage;

  ReviewUser({this.id, this.name, this.userImage});

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      userImage: json['avatarURL']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'avatarURL': userImage};
  }
}
