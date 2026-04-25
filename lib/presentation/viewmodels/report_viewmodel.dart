import 'package:flutter/cupertino.dart';
import '../../data/models/requestmodel/report.dart';
import '../../data/repositories/report_repository_impl.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportRepository repository;

  ReportViewModel(this.repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  Future<bool> sendReport(ReportRequest reportRequest) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await repository.sendReport(reportRequest);
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