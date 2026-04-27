import 'package:dio/dio.dart';
import '../../repositories/user_repository.dart';

class SendFcmTokenUseCase {
  final UserRepository repository;

  SendFcmTokenUseCase(this.repository);

  Future<Response> call(String userId, String token, String role) {
    return repository.updateFcmToken(userId, token, role);
  }
}
