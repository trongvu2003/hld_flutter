
import '../datasources/services/appointment_service.dart';
import '../models/requestmodel/appointment.dart';
import '../models/responsemodel/appointment.dart';

class AppointmentRepository {
  final AppointmentService appointmentService;

  AppointmentRepository(this.appointmentService);

  Future<List<AppointmentResponse>> getAppointmentUser(String userId) async {
    return await appointmentService.getAppointmentUser(userId);
  }

  Future<CreateAppointmentResponse> createAppointment(
    String accessToken,
    CreateAppointmentRequest request,
  ) async {
    return await appointmentService.createAppointment(accessToken, request);
  }

  Future<CancelAppointmentResponse> cancelAppointment(String id) async {
    return await appointmentService.cancelAppointment(id);
  }

  Future<UpdateAppointmentResponse> updateAppointment(
    String id,
    UpdateAppointmentRequest request,
  ) async {
    return await appointmentService.updateAppointment(id, request);
  }

  Future<UpdateAppointmentResponse> deleteAppointmentById(String id) async {
    return await appointmentService.deleteAppointmentById(id);
  }

  Future<List<AppointmentResponse>> getAppointmentDoctor(
    String doctorId,
  ) async {
    return await appointmentService.getAppointmentDoctor(doctorId);
  }

  Future<UpdateAppointmentResponse> confirmAppointment(String id) async {
    return await appointmentService.confirmAppointment(id);
  }
}
