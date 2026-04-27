import '../../../data/models/requestmodel/report.dart';
import '../../repositories/report_repository.dart';

class SendReportUseCase {
  final ReportRepository repository;

  SendReportUseCase(this.repository);

  Future<void> call(ReportRequest request) {
    return repository.sendReport(request);
  }
}
