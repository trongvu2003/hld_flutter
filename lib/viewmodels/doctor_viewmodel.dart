import 'package:flutter/cupertino.dart';
import 'package:hld_flutter/models/responsemodel/doctor.dart';
import 'package:hld_flutter/repositories/doctor_repository.dart';

class DoctorViewModel extends ChangeNotifier {
  final DoctorRepository repository;

  DoctorViewModel(this.repository);

  List<GetDoctorResponse> doctors = [];
  GetDoctorResponse? selectedDoctor;
  bool isLoading = false;
  bool isError = false;
  String error = '';

  DoctorAvailableSlotsResponse? doctorSlots;

  Future<void> fetchDoctors() async {
    if (doctors.isNotEmpty) return;
    isLoading = true;
    isError = false;
    notifyListeners();

    try {
      final res = await repository.getDoctors();
      doctors = res;
      print('LẤY BÁC SĨ THÀNH CÔNG: ${doctors.length} người');
    } catch (e) {
      error = e.toString();
      isError = true;
      isLoading = false;
      print('LỖI FETCH DOCTORS: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<GetDoctorResponse?> getDoctorById(String doctorId) async {
    isLoading = true;
    isError = false;
    error = '';
    notifyListeners();

    try {
      selectedDoctor = await repository.getDoctorById(doctorId);
      print('LẤY BÁC SĨ THÀNH CÔNG: ${selectedDoctor?.name}');
      return selectedDoctor;
    } catch (e) {
      isError = true;
      error = e.toString();
      print('LỖI getDoctorById: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<DoctorAvailableSlotsResponse?> fetchAvailableSlots(
    String doctorId,
  ) async {
    isLoading = true;
    isError = false;
    error = '';
    notifyListeners();

    try {
      final res = await repository.getAvailableSlots(doctorId);
      doctorSlots = res;
      return res;
    } catch (e) {
      isError = true;
      error = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
