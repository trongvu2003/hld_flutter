import 'package:flutter/cupertino.dart';
import '../models/requestmodel/appointment.dart';
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
      print("LẤY LỊCH SỬ THẤT BẠI: " + error);
      isError = true;
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<CreateAppointmentResponse?> createAppointment(
    String accessToken,
    CreateAppointmentRequest request,
  ) async {
    isLoading = true;
    isError = false;
    error = '';
    notifyListeners();

    try {
      final res = await repository.createAppointment(accessToken, request);
      print("ĐẶT LỊCH THÀNH CÔNG: ${res.message}");
      return res;
    } catch (e) {
      error = e.toString();
      isError = true;
      print("ĐẶT LỊCH THẤT BẠI: $error");
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
