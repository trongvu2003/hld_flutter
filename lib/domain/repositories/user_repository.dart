import 'package:dio/dio.dart';
import '../../data/models/responsemodel/user_response.dart';

abstract class UserRepository {
  Future<User> getUser(String id);

  Future<User?> updateUserByID({
    required String id,
    MultipartFile? avatarURL,
    String? name,
    String? email,
    String? address,
    String? phone,
    String? password,
    String? role,
  });

  Future<void> updateFcmToken(String userId, String token, String model);
}
