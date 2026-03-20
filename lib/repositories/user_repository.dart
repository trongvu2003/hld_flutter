import '../models/responsemodel/login_response.dart';
import '../services/auth_service.dart';

class UserRepository {
  final AuthService authService;

  UserRepository(this.authService);

  Future<LoginResponse?> login(String email, String password) async {
    return await authService.login(email, password);
  }
}
