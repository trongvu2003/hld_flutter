import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/responsemodel/doctor.dart';

class DoctorService {
  final Dio dio = Dio(
    BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? "http://10.0.2.2:4000"),
  );

  Future<List<GetDoctorResponse>> getDoctors() async {
    try {
      final res = await dio.get('/doctor/get-all');
      if (res.statusCode == 200) {
        List<dynamic> data = res.data;
        return data
            .map((dynamic item) => GetDoctorResponse.fromJson(item))
            .toList();
      } else {
        throw Exception('Lỗi API: Server trả về mã ${res.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Lỗi khi tải danh sách bác sĩ: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Lỗi kết nối mạng: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<GetDoctorResponse> getDoctorById(String doctorId) async {
    try {
      final res = await dio.get('/doctor/get-by-id/$doctorId');
      if (res.statusCode == 200) {
        return GetDoctorResponse.fromJson(res.data);
      } else {
        throw Exception('Lỗi API: Server trả về mã ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
