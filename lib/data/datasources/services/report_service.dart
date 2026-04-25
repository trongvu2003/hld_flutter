import 'package:dio/dio.dart';
import '../../models/requestmodel/report.dart';

class ReportService {
  final Dio dio;
  ReportService(this.dio);

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
