import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository repository;

  AuthViewModel(this.repository);

  String email = '';
  String password = '';
  bool isLoading = false;
  bool isAuthenticated = false;
  String? role;
  String? errorMessage;
  Map<String, dynamic>? currentUser;

  Future<void> fetchCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    print("TOKEN: $token");
    if (token == null) return;
    final decoded = JwtDecoder.decode(token);
    print("DECODED: $decoded");
    currentUser = decoded;
    notifyListeners();
  }

  Future<bool> signIn() async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      errorMessage = "Vui lòng nhập email và mật khẩu";
      notifyListeners();
      return false;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final result = await repository.login(email, password);
    isLoading = false;
    if (result != null) {
      final token = result.accessToken;
      await _saveToken(token);
      role = _extractRole(token);
      isAuthenticated = true;
      await fetchCurrentUser();
      notifyListeners();
      return true;
    } else {
      errorMessage = "Sai tài khoản hoặc mật khẩu";
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  String _extractRole(String token) {
    try {
      final decoded = JwtDecoder.decode(token);
      return decoded['role'] ?? 'User';
    } catch (e) {
      return 'User';
    }
  }
}
