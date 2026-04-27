import 'package:dio/dio.dart';
import '../../../data/models/responsemodel/user_response.dart';
import '../../repositories/user_repository.dart';

class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  Future<User?> call({
    required String id,
    MultipartFile? avatarURL,
    String? name,
    String? email,
    String? address,
    String? phone,
    String? password,
  }) {
    return repository.updateUserByID(
      id: id,
      avatarURL: avatarURL,
      name: name,
      email: email,
      address: address,
      phone: phone,
      password: password,
    );
  }
}
