import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final Dio dio = Dio(
    BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? "http://10.0.2.2:4000"),
  );

  Future<Response> login(String email, String password) {
    return dio.post('/auth/login', data: {
      "email": email,
      "password": password,
    });
  }
}