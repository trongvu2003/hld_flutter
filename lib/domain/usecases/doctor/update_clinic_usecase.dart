import '../../../data/models/requestmodel/doctor.dart';
import '../../repositories/doctor_repository.dart';

class UpdateClinicUseCase {
  final DoctorRepository repository;

  UpdateClinicUseCase(this.repository);

  Future<bool> call(String doctorId, ModifyClinicRequest request) {
    return repository.updateClinicInfo(doctorId, request);
  }
}
