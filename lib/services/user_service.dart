import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/responsemodel/user_response.dart';


class UserService {
  final Dio dio = Dio(
    BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? "http://10.0.2.2:4000"),
  );

  Future<User> getUser(String id) async {
    final response = await dio.get("/user/getuserbyid/$id");
    return User.fromJson(response.data);
  }
}