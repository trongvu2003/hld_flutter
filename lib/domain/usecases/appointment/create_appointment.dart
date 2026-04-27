import '../../../data/models/requestmodel/appointment.dart';
import '../../../data/models/responsemodel/appointment.dart';
import '../../repositories/appointment_repository.dart';

class CreateAppointmentUseCase {
  final AppointmentRepository repository;

  CreateAppointmentUseCase(this.repository);

  Future<CreateAppointmentResponse> call(
    String token,
    CreateAppointmentRequest request,
  ) {
    return repository.createAppointment(token, request);
  }
}
