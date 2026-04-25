import 'dart:convert';
import 'package:dio/dio.dart';
import '../../models/responsemodel/specialty.dart';

class SpecialtyService {
  final Dio dio;
  SpecialtyService(this.dio);

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

  Future<GetSpecialtyResponse> getSpecialtyById(String specialtyId) async {
    final res = await dio.get('/specialty/doctors/$specialtyId');
    if (res.statusCode == 200 && res.data != null) {
      return GetSpecialtyResponse.fromJson(res.data);
    } else {
      throw Exception('Không thể tải thông tin chuyên khoa.');
    }
  }

  Future<GetSpecialtyResponse> getSpecialtyByName(String name) async {
    final response = await dio.post(
      '/specialty/specialty-by-name',
      data: jsonEncode({'name': name}),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    if (response.statusCode == 200) {
      return GetSpecialtyResponse.fromJson(response.data);
    }
    throw Exception(
      'Failed to fetch specialty by name: ${response.statusCode}',
    );
  }
}
