import '../../../data/models/requestmodel/appointment.dart';
import '../../../data/models/responsemodel/appointment.dart';
import '../../repositories/appointment_repository.dart';

class UpdateAppointmentUseCase {
  final AppointmentRepository repository;

  UpdateAppointmentUseCase(this.repository);

  Future<UpdateAppointmentResponse> call(
    String id,
    UpdateAppointmentRequest request,
  ) {
    return repository.updateAppointment(id, request);
  }
}
