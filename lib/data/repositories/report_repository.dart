import '../datasources/services/report_service.dart';
import '../models/requestmodel/report.dart';

class ReportRepository {
  final ReportService service;
  ReportRepository(this.service);

  Future<void> sendReport(ReportRequest reportRequest) async {
    return service.sendReport(reportRequest);
  }
}
