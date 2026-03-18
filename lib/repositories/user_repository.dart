import '../services/auth_service.dart';

class UserRepository {
  final AuthService authService;

  UserRepository(this.authService);

  Future<Map<String, dynamic>?> login(
      String email, String password) async {
    try {
      final res = await authService.login(email, password);

      if (res.statusCode == 201) {
        return res.data;
      } else {
        throw Exception("Login failed");
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }
}