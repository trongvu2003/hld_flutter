import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hld_flutter/data/models/requestmodel/doctor.dart';
import '../../models/responsemodel/doctor.dart';


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

  Future<DoctorAvailableSlotsResponse> getAvailableSlots(
    String doctorId,
  ) async {
    try {
      final res = await dio.get('/doctor/getAvailableWorkingTime/$doctorId');
      if (res.statusCode == 200) {
        return DoctorAvailableSlotsResponse.fromJson(res.data);
      } else {
        throw Exception('Lỗi API: Server trả về mã ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<Response> applyForDoctor(String userId, FormData formData) async {
    return await dio.patch("/doctor/apply-for-doctor/$userId", data: formData);
  }

  Future<bool> updateClinicInfo(
    String doctorId,
    ModifyClinicRequest request,
  ) async {
    try {
      FormData formData = FormData();

      //  Thêm các trường Text cơ bản
      formData.fields.addAll([
        MapEntry('address', request.address),
        MapEntry('description', request.description),
        MapEntry('hasHomeService', request.hasHomeService.toString()),
        MapEntry('isClinicPaused', request.isClinicPaused.toString()),
        MapEntry('specialtyId', request.specialtyId),
      ]);

      // Encode các danh sách (List) thành chuỗi JSON
      formData.fields.add(
        MapEntry(
          'workingHours',
          jsonEncode(request.workingHours.map((e) => e.toJson()).toList()),
        ),
      );
      formData.fields.add(
        MapEntry(
          'oldWorkingHours',
          jsonEncode(request.oldWorkingHours.map((e) => e.toJson()).toList()),
        ),
      );
      formData.fields.add(
        MapEntry(
          'services',
          jsonEncode(request.services.map((e) => e.toJson()).toList()),
        ),
      );
      formData.fields.add(
        MapEntry(
          'oldServices',
          jsonEncode(request.oldServices.map((e) => e.toJson()).toList()),
        ),
      );

      // Xử lý danh sách file ảnh
      for (String path in request.images) {
        if (path.isNotEmpty) {
          formData.files.add(
            MapEntry(
              'images',
              await MultipartFile.fromFile(
                path,
                filename: path.split('/').last,
              ),
            ),
          );
        }
      }
      // Gửi Request POST
      final res = await dio.post(
        "/doctor/doctor/$doctorId/updateclinic",
        data: formData,
      );

      return res.statusCode == 200 || res.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(
        'Lỗi API Cập nhật phòng khám: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
