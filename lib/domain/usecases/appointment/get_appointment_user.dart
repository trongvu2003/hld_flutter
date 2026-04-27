import '../../../data/models/responsemodel/appointment.dart';
import '../../repositories/appointment_repository.dart';

class GetAppointmentUserUseCase {
  final AppointmentRepository repository;

  GetAppointmentUserUseCase(this.repository);

  Future<List<AppointmentResponse>> call(String userId) {
    return repository.getAppointmentUser(userId);
  }
}
