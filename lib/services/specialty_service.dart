import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/responsemodel/specialty.dart';

class SpecialtyService {
  final Dio dio = Dio(
    BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? "http://10.0.2.2:4000"),
  );

  Future<List<GetSpecialtyResponse>> getAllSpecialties() async {
    try {
      final res = await dio.get('/specialty/get-all');
      if (res.statusCode == 200 && res.data != null) {
        List<dynamic> dataList = res.data;
        return dataList
            .map((json) => GetSpecialtyResponse.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print("Lỗi tại getAllSpecialties: $e");
      throw Exception(
        'Không thể tải danh sách chuyên khoa. Vui lòng thử lại sau.',
      );
    }
  }
}
