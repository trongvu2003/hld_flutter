import 'package:dio/dio.dart';
import '../../models/responsemodel/login_response.dart';

class AuthService {
  final Dio dio;
  AuthService(this.dio);

  Future<LoginResponse?> login(String email, String password) async {
    try {
      final res = await dio.post(
        '/auth/login',
        data: {"email": email, "password": password},
      );
      return LoginResponse.fromJson(res.data);
    } catch (e) {
      return null;
    }
  }
}
