import '../../domain/repositories/report_repository.dart';
import '../datasources/services/report_service.dart';
import '../models/requestmodel/report.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportService service;

  ReportRepositoryImpl(this.service);

  Future<void> sendReport(ReportRequest reportRequest) async {
    return service.sendReport(reportRequest);
  }
}
