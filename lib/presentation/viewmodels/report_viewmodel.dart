import 'package:flutter/cupertino.dart';
import '../../data/models/requestmodel/report.dart';
import '../../domain/usecases/report/send_report_usecase.dart';

class ReportViewModel extends ChangeNotifier {
  final SendReportUseCase sendReportUseCase;

  ReportViewModel({required this.sendReportUseCase});

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String _error = '';

  String get error => _error;

  Future<bool> sendReport(ReportRequest reportRequest) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await sendReportUseCase(reportRequest);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
