import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetCurrentUserUseCase {
  Future<Map<String, dynamic>?> call() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) return null;

    return JwtDecoder.decode(token);
  }
}
