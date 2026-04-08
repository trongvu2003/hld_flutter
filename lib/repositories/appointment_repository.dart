import 'package:hld_flutter/models/requestmodel/appointment.dart';
import 'package:hld_flutter/services/appointment_service.dart';
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
}
