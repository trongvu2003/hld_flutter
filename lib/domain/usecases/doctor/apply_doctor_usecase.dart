import '../../../data/models/requestmodel/doctor.dart';
import '../../../data/models/responsemodel/doctor.dart';
import '../../repositories/doctor_repository.dart';

class ApplyDoctorUseCase {
  final DoctorRepository repository;

  ApplyDoctorUseCase(this.repository);

  Future<ApplyDoctorResponse> call(String userId, ApplyDoctorRequest request) {
    return repository.applyForDoctor(userId, request);
  }
}
