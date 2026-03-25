class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String? avatarURL;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    this.avatarURL,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'],
      avatarURL: json['avatarURL'],
    );
  }
}