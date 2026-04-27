import '../../../data/models/responsemodel/appointment.dart';
import '../../repositories/appointment_repository.dart';

class GetAppointmentDoctorUseCase {
  final AppointmentRepository repository;

  GetAppointmentDoctorUseCase(this.repository);

  Future<List<AppointmentResponse>> call(String doctorId) {
    return repository.getAppointmentDoctor(doctorId);
  }
}
