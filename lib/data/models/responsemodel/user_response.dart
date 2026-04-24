class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String address;
  final String role;
  final String createdAt;
  final String updatedAt;
  final String? avatarURL;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.address,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.avatarURL,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      avatarURL: json['avatarURL'],
    );
  }
}
