import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/responsemodel/review_response.dart';

class ReviewService {
  final Dio dio = Dio(
    BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? "http://10.0.2.2:4000"),
  );

  Future<List<ReviewResponse>> getReviewsByDoctor(String doctorId) async {
    try {
      final res = await dio.get('/review/doctor/$doctorId');

      if (res.statusCode == 200) {
        List<dynamic> data = res.data;

        return data.map((e) => ReviewResponse.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi API: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
