import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/responsemodel/user_response.dart';
import '../repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository repository;

  UserViewModel(this.repository);
  User? user;
  bool isLoading = false;

  Future<void> loadUser() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) return;

      final decoded = JwtDecoder.decode(token);
      final userId = decoded['userId'];

      user = await repository.getUser(userId);
    } catch (e) {
      print("USER ERROR: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}