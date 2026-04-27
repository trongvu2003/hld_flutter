import '../../../data/models/responsemodel/user_response.dart';
import '../../repositories/user_repository.dart';

class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<User> call(String userId) {
    return repository.getUser(userId);
  }
}