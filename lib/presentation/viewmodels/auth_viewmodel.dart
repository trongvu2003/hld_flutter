import 'package:flutter/material.dart';
import '../../domain/usecases/auth/extract_role_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/save_token_usecase.dart';

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final SaveTokenUseCase saveTokenUseCase;
  final ExtractRoleUseCase extractRoleUseCase;

  AuthViewModel({
    required this.loginUseCase,
    required this.saveTokenUseCase,
    required this.extractRoleUseCase,
  });

  String email = '';
  String password = '';
  bool isLoading = false;
  bool isAuthenticated = false;
  String? role;
  String? errorMessage;


  Future<bool> signIn() async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      errorMessage = "Vui lòng nhập email và mật khẩu";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await loginUseCase(email, password);

    isLoading = false;

    if (result != null) {
      final token = result.accessToken;

      await saveTokenUseCase(token);
      role = extractRoleUseCase(token);

      isAuthenticated = true;

      notifyListeners();
      return true;
    } else {
      errorMessage = "Sai tài khoản hoặc mật khẩu";
      notifyListeners();
      return false;
    }
  }
}
