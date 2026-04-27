import '../../../data/models/responsemodel/appointment.dart';
import '../../repositories/appointment_repository.dart';

class DeleteAppointmentUseCase {
  final AppointmentRepository repository;

  DeleteAppointmentUseCase(this.repository);

  Future<UpdateAppointmentResponse> call(String id) {
    return repository.deleteAppointmentById(id);
  }
}
