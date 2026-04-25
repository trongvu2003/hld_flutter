import 'package:dio/dio.dart';
import 'package:hld_flutter/data/datasources/services/user_service.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/requestmodel/tokenrequest.dart';
import '../models/responsemodel/user_response.dart';

class UserRepositoryImpl implements UserRepository {
  final UserService userService;

  UserRepositoryImpl(this.userService);

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

  Future<Response> updateFcmToken(
    String userId,
    String token,
    String model,
  ) async {
    final request = TokenRequest(token: token, userModel: model);

    return await userService.updateFcmToken(userId, request);
  }
}
