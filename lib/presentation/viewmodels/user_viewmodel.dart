import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/responsemodel/user_response.dart';
import '../../domain/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository repository;

  UserViewModel(this.repository);

  User? currentUser; // Thông tin của chính mình
  User? userOfThisProfile; // Thông tin của người khác
  bool isLoading = false;

  Future<void> loadCurrentUser() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) return;

      final decoded = JwtDecoder.decode(token);
      final userId = decoded['userId'];

      currentUser = await repository.getUser(userId);
    } catch (e) {
      print("LOAD CURRENT USER ERROR: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadOtherUser(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Gọi API lấy user theo ID truyền vào, không dùng Token ID
      userOfThisProfile = await repository.getUser(userId);
    } catch (e) {
      print("LOAD OTHER USER ERROR: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser({
    File? avatarFile,
    String? name,
    String? email,
    String? address,
    String? phone,
    String? password,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) return;
      final decoded = JwtDecoder.decode(token);
      final userId = decoded['userId'];
      MultipartFile? avatarMultipart;
      if (avatarFile != null) {
        avatarMultipart = await MultipartFile.fromFile(
          avatarFile.path,
          filename: avatarFile.path.split('/').last,
        );
      }

      final updatedUser = await repository.updateUserByID(
        id: userId,
        avatarURL: avatarMultipart,
        name: name,
        email: email,
        address: address,
        phone: phone,
        password: password,
      );

      if (updatedUser != null) {
        await loadCurrentUser();
      }
    } catch (e) {
      print("UPDATE USER ERROR: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> sendFcmToken(String userId, String role, String token) async {
    try {
      final res = await repository.updateFcmToken(userId, token, role);

      if (res.statusCode == 200 || res.statusCode == 204) {
        debugPrint("FCM: Gửi token thành công");
      } else {
        debugPrint("FCM: Gửi thất bại ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("FCM: Lỗi gửi token $e");
    }
  }
}
