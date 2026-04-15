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

  bool isCancelling = false;

  Future<bool> cancelAppointment(String appointmentId) async {
    isCancelling = true;
    notifyListeners();

    try {
      final res = await repository.cancelAppointment(appointmentId);
      print("HUỶ LỊCH THÀNH CÔNG: ${res.message}");

      // CẬP NHẬT GIAO DIỆN NGAY LẬP TỨC
      final index = appointments.indexWhere((item) => item.id == appointmentId);
      if (index != -1) {
        appointments[index] = appointments[index].copyWith(status: 'cancelled');
      }
      return true;
    } catch (e) {
      error = e.toString();
      print("HUỶ LỊCH THẤT BẠI: $error");
      return false;
    } finally {
      isCancelling = false;
      notifyListeners();
    }
  }

  Future<bool> updateAppointment(
    String id,
    UpdateAppointmentRequest request,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await repository.updateAppointment(id, request);
      // Cập nhật lại danh sách appointments đang có trong RAM
      final index = appointments.indexWhere((element) => element.id == id);
      if (index != -1) {
        appointments[index] = appointments[index].copyWith(
          date: request.date,
          time: request.time,
          notes: request.notes,
        );
      }

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAppointmentById(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await repository.deleteAppointmentById(id);
      print("XOÁ LỊCH THÀNH CÔNG: ${res.message}");
      appointments.removeWhere((item) => item.id == id);
      return true;
    } catch (e) {
      error = e.toString();
      print("XOÁ LỊCH THẤT BẠI: $error");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
