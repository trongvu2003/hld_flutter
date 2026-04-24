import '../../domain/repositories/auth_repository.dart';
import '../datasources/services/auth_service.dart';
import '../models/responsemodel/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;

  AuthRepositoryImpl(this.authService);

  Future<LoginResponse?> login(String email, String password) async {
    return await authService.login(email, password);
  }
}
