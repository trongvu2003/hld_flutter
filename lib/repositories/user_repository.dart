import 'package:dio/dio.dart';
import 'package:hld_flutter/models/responsemodel/user_response.dart';
import 'package:hld_flutter/services/user_service.dart';

class UserRepository {
  final UserService userService;

  UserRepository(this.userService);

  Future<User> getUser(String id) {
    return userService.getUser(id);
  }


  Future<User?> updateUserByID({
    required String id,
    MultipartFile? avatarURL,
    String? name,
    String? email,
    String? address,
    String? phone,
    String? password,
    String? role,
  }) {
    return userService.updateUserByID(
      id: id,
      avatarURL: avatarURL,
      name: name,
      email: email,
      address: address,
      phone: phone,
      password: password,
      role: role,
    );
  }
}
