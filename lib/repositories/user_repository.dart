import 'package:hld_flutter/models/responsemodel/user_response.dart';
import 'package:hld_flutter/services/user_service.dart';

class UserRepository {
  final UserService userService;

  UserRepository(this.userService);

  Future<User> getUser(String id) {
    return userService.getUser(id);
  }
}
