import 'package:shared_preferences/shared_preferences.dart';

class SaveTokenUseCase {
  Future<void> call(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }
}
