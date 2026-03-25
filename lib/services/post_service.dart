import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/responsemodel/post.dart';

class PostService {
  final Dio dio = Dio(
    BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? "http://10.0.2.2:4000"),
  );

  Future<PostPageResponse> getAllPosts(int skip, int limit) async {
    try {
      final res = await dio.get(
        '/post',
        queryParameters: {'skip': skip, 'limit': limit},
      );

      return PostPageResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response != null
            ? 'Server error: ${e.response?.statusCode}'
            : 'Network error: ${e.message}',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
