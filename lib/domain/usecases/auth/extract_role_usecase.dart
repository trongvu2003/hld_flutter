import 'package:jwt_decoder/jwt_decoder.dart';

class ExtractRoleUseCase {
  String call(String token) {
    try {
      final decoded = JwtDecoder.decode(token);
      return decoded['role'] ?? 'User';
    } catch (e) {
      return 'User';
    }
  }
}
