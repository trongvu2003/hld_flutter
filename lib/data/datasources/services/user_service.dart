import 'package:dio/dio.dart';
import '../../models/requestmodel/tokenrequest.dart';
import '../../models/responsemodel/user_response.dart';

class UserService {
  final Dio dio;
  UserService(this.dio);

  Future<User> getUser(String id) async {
    final response = await dio.get("/user/getuserbyid/$id");
    return User.fromJson(response.data);
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
  }) async {
    try {
      FormData formData = FormData.fromMap({
        if (avatarURL != null) "avatarURL": avatarURL,
        if (name != null) "name": name,
        if (email != null) "email": email,
        if (address != null) "address": address,
        if (phone != null) "phone": phone,
        if (password != null) "password": password,
        if (role != null) "role": role,
      });

      final response = await dio.put(
        "/admin/updateUser/$id",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Update user error: $e");
      return null;
    }
  }

  Future<Response> updateFcmToken(String userId, TokenRequest request) async {
    return await dio.put('/user/$userId/fcm-token', data: request.toJson());
  }
}
