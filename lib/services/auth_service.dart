import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/responsemodel/login_response.dart';

class AuthService {
  final Dio dio = Dio(
    BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? "http://10.0.2.2:4000"),
  );

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
