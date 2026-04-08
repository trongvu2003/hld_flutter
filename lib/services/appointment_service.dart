import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/requestmodel/appointment.dart';
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

  Future<CreateAppointmentResponse> createAppointment(String accessToken,
      CreateAppointmentRequest request,) async {
    try {
      final res = await dio.post(
        '/appointments/book',
        data: request.toJson(),
        options: Options(
          headers: {
            'accessToken': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return CreateAppointmentResponse.fromJson(
          res.data as Map<String, dynamic>,
        );
      } else {
        throw Exception('Lỗi API: Server trả về mã ${res.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Lỗi server';
        throw Exception(message);
      } else {
        throw Exception('Không thể kết nối server');
      }
    } catch (e) {
      throw Exception('Lỗi: ${e.toString()}');
    }
  }
}
