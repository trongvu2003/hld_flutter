import '../../data/models/requestmodel/report.dart';

abstract class ReportRepository {
  Future<void> sendReport(ReportRequest reportRequest);
}