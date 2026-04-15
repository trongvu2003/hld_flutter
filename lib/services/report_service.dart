import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/requestmodel/report.dart';

class ReportService {
  final Dio dio = Dio(
    BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? "http://10.0.2.2:4000"),
  );

  Future<void> sendReport(ReportRequest reportRequest) async {
    try {
      final res = await dio.post('/report', data: reportRequest.toJson());
      if (res.statusCode == 200|| res.statusCode == 201) {
        print('Báo cáo thành công');
      } else {
        throw Exception('Lỗi API: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception("Lỗi " + e.toString());
    }
  }
}
