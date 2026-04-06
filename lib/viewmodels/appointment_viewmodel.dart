import 'package:flutter/cupertino.dart';
import '../models/responsemodel/appointment.dart';
import '../repositories/appointment_repository.dart';

class AppointmentViewModel extends ChangeNotifier {
  final AppointmentRepository repository;

  AppointmentViewModel(this.repository);

  List<AppointmentResponse> appointments = [];
  bool isLoading = false;
  bool isError = false;
  String error = '';

  Future<List<AppointmentResponse>> getAppointmentUser(String userId) async {
    isLoading = true;
    isError = false;
    error = '';
    notifyListeners();

    try {
      final res = await repository.getAppointmentUser(userId);
      appointments = res;
      print("LẤY LỊCH SỬ THÀNH CÔNG: ${appointments.length} items");
      return appointments;
    } catch (e) {
      error = e.toString();
      print("LẤY LỊCH SỬ THẤT BẠI: "+ error);
      isError = true;
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
