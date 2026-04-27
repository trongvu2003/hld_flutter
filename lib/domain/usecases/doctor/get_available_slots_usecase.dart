import '../../../data/models/responsemodel/doctor.dart';
import '../../repositories/doctor_repository.dart';

class GetAvailableSlotsUseCase {
  final DoctorRepository repository;

  GetAvailableSlotsUseCase(this.repository);

  Future<DoctorAvailableSlotsResponse> call(String doctorId) {
    return repository.getAvailableSlots(doctorId);
  }
}
