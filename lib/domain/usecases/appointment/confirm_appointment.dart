import '../../../data/models/responsemodel/appointment.dart';
import '../../repositories/appointment_repository.dart';

class ConfirmAppointmentUseCase {
  final AppointmentRepository repository;

  ConfirmAppointmentUseCase(this.repository);

  Future<UpdateAppointmentResponse> call(String id) {
    return repository.confirmAppointment(id);
  }
}
