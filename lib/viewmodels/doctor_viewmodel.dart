import 'package:flutter/cupertino.dart';
import 'package:hld_flutter/models/responsemodel/doctor.dart';
import 'package:hld_flutter/repositories/doctor_repository.dart';

class DoctorViewModel extends ChangeNotifier {
  final DoctorRepository repository;

  DoctorViewModel(this.repository);

  List<GetDoctorResponse> doctors = [];
  bool isLoading = false;
  bool isError = false;
  String error = '';

  Future<void> fetchDoctors() async {
    if (doctors.isNotEmpty) return;
    isLoading = true;
    isError = false;
    notifyListeners();

    try {
      final res = await repository.getDoctors();
      doctors = res;
      print('✅ LẤY BÁC SĨ THÀNH CÔNG: ${doctors.length} người');
    } catch (e) {
      error = e.toString();
      isError = true;
      isLoading = false;
      print('🔴 LỖI FETCH DOCTORS: $e'); // In lỗi to ra terminal
    }
    isLoading = false;
    notifyListeners();
  }
}
