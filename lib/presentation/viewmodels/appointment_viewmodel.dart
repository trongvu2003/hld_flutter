import 'package:flutter/cupertino.dart';
import '../../data/models/requestmodel/appointment.dart';
import '../../data/models/responsemodel/appointment.dart';
import '../../domain/usecases/appointment/cancel_appointment_usecase.dart';
import '../../domain/usecases/appointment/confirm_appointment_usecase.dart';
import '../../domain/usecases/appointment/create_appointment_usecase.dart';
import '../../domain/usecases/appointment/delete_appointment_usecase.dart';
import '../../domain/usecases/appointment/get_appointment_doctor_usecase.dart';
import '../../domain/usecases/appointment/get_appointment_user_usecase.dart';
import '../../domain/usecases/appointment/update_appointment_usecase.dart';

class AppointmentViewModel extends ChangeNotifier {
  final GetAppointmentUserUseCase getAppointmentUserUC;
  final GetAppointmentDoctorUseCase getAppointmentDoctorUC;
  final CreateAppointmentUseCase createAppointmentUC;
  final CancelAppointmentUseCase cancelAppointmentUC;
  final UpdateAppointmentUseCase updateAppointmentUC;
  final DeleteAppointmentUseCase deleteAppointmentUC;
  final ConfirmAppointmentUseCase confirmAppointmentUC;

  AppointmentViewModel({
    required this.getAppointmentUserUC,
    required this.getAppointmentDoctorUC,
    required this.createAppointmentUC,
    required this.cancelAppointmentUC,
    required this.updateAppointmentUC,
    required this.deleteAppointmentUC,
    required this.confirmAppointmentUC,
  });

  List<AppointmentResponse> appointments = [];
  bool isLoading = true;
  bool isError = false;
  String error = '';

  Future<List<AppointmentResponse>> getAppointmentUser(String userId) async {
    isLoading = true;
    isError = false;
    error = '';
    notifyListeners();

    try {
      final res = await getAppointmentUserUC(userId);
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
      final res = await createAppointmentUC(accessToken, request);
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
      final res = await cancelAppointmentUC(appointmentId);
      print("HUỶ LỊCH THÀNH CÔNG: ${res.message}");

      // CẬP NHẬT GIAO DIỆN NGAY LẬP TỨC
      final index = appointments.indexWhere((item) => item.id == appointmentId);
      if (index != -1) {
        appointments[index] = appointments[index].copyWith(status: 'cancelled');
      }

      final indexDoctor = appointmentsfordoctor.indexWhere(
        (item) => item.id == appointmentId,
      );
      if (indexDoctor != -1) {
        appointmentsfordoctor[indexDoctor] = appointmentsfordoctor[indexDoctor]
            .copyWith(status: 'cancelled');
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
      await updateAppointmentUC(id, request);
      // Cập nhật lại danh sách appointments đang có trong RAM
      final index = appointments.indexWhere((element) => element.id == id);
      if (index != -1) {
        appointments[index] = appointments[index].copyWith(
          date: request.date,
          time: request.time,
          notes: request.notes,
        );
      }

      final indexDoctor = appointmentsfordoctor.indexWhere(
        (element) => element.id == id,
      );
      if (indexDoctor != -1) {
        appointmentsfordoctor[indexDoctor] = appointmentsfordoctor[indexDoctor]
            .copyWith(
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
      final res = await deleteAppointmentUC(id);
      print("XOÁ LỊCH THÀNH CÔNG: ${res.message}");
      appointments.removeWhere((item) => item.id == id);
      appointmentsfordoctor.removeWhere((item) => item.id == id);
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

  List<AppointmentResponse> appointmentsfordoctor = [];

  Future<List<AppointmentResponse>> getAppointmentDoctor(
    String doctorId,
  ) async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await getAppointmentDoctorUC(doctorId);
      print(
        "LẤY LỊCH SỬ THÀNH CÔNG cho bác sĩ: ${appointmentsfordoctor.length} items",
      );
      appointmentsfordoctor = res;
      return appointmentsfordoctor;
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

  Future<bool> confirmAppointmentDone(
    String appointmentId,
    String userId,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await confirmAppointmentUC(appointmentId);
      print("Xác nhận đã hoàn thành: ${res.message}");
      await getAppointmentUser(userId);
      await getAppointmentDoctor(userId);

      return true;
    } catch (e) {
      error = e.toString();
      print("Lỗi xác nhận/API: $error");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadDoctorAppointments(String doctorId) async {
    isLoading = true;
    notifyListeners();
    try {
      appointmentsfordoctor = await getAppointmentDoctorUC(doctorId);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
