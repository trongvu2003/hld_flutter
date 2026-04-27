import '../../../data/models/responsemodel/appointment.dart';
import '../../repositories/appointment_repository.dart';

class CancelAppointmentUseCase {
  final AppointmentRepository repository;

  CancelAppointmentUseCase(this.repository);

  Future<CancelAppointmentResponse> call(String id) {
    return repository.cancelAppointment(id);
  }
}
