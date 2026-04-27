import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../data/models/responsemodel/user_response.dart';
import '../../domain/usecases/user/get_current_user_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/user/send_fcm_token_usecase.dart';
import '../../domain/usecases/user/update_user_usecase.dart';

class UserViewModel extends ChangeNotifier {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final SendFcmTokenUseCase sendFcmTokenUseCase;

  UserViewModel({
    required this.getCurrentUserUseCase,
    required this.getUserByIdUseCase,
    required this.updateUserUseCase,
    required this.sendFcmTokenUseCase,
  });

  User? currentUser; // Thông tin của chính mình
  User? userOfThisProfile; // Thông tin của người khác
  bool isLoading = false;

  Future<void> loadCurrentUser() async {
    isLoading = true;
    notifyListeners();

    try {
      final userId = await getCurrentUserUseCase();

      if (userId == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      currentUser = await getUserByIdUseCase(userId);
    } catch (e) {
      debugPrint("LOAD CURRENT USER ERROR: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadOtherUser(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      userOfThisProfile = await getUserByIdUseCase(userId);
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
      final userId = await getCurrentUserUseCase();
      if (userId == null) {
        isLoading = false;
        notifyListeners();
        return;
      }
      MultipartFile? avatarMultipart;
      if (avatarFile != null) {
        avatarMultipart = await MultipartFile.fromFile(
          avatarFile.path,
          filename: avatarFile.path.split('/').last,
        );
      }

      final updatedUser = await updateUserUseCase(
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
      final res = await sendFcmTokenUseCase(userId, token, role);

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
