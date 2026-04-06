import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/responsemodel/appointment.dart';

class AppointmentService {
  final Dio dio = Dio(
    BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? "http://10.0.2.2:4000"),
  );

  Future<List<AppointmentResponse>> getAppointmentUser(String id) async {
    print("${dio.options.baseUrl}appointments/patient/$id");
    try {
      final res = await dio.get('/appointments/patient/$id');
      if (res.statusCode == 200) {
        List<dynamic> data = res.data;
        return data
            .map(
              (item) =>
                  AppointmentResponse.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Lỗi API: Server trả về mã ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi ' + e.toString());
    }
  }
}
