import '../../data/models/requestmodel/appointment.dart';
import '../../data/models/responsemodel/appointment.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentResponse>> getAppointmentUser(String userId);

  Future<CreateAppointmentResponse> createAppointment(
      String accessToken,
      CreateAppointmentRequest request,
      );

  Future<CancelAppointmentResponse> cancelAppointment(String id);

  Future<UpdateAppointmentResponse> updateAppointment(
      String id,
      UpdateAppointmentRequest request,
      );

  Future<UpdateAppointmentResponse> deleteAppointmentById(String id);

  Future<List<AppointmentResponse>> getAppointmentDoctor(String doctorId);

  Future<UpdateAppointmentResponse> confirmAppointment(String id);
}