class TokenRequest {
  final String token;
  final String userModel;

  TokenRequest({required this.token, required this.userModel});

  // Convert từ JSON -> Object
  factory TokenRequest.fromJson(Map<String, dynamic> json) {
    return TokenRequest(token: json['token'], userModel: json['userModel']);
  }

  // Convert từ Object -> JSON
  Map<String, dynamic> toJson() {
    return {'token': token, 'userModel': userModel};
  }
}
