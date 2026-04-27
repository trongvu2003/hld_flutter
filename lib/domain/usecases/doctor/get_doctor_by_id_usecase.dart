import '../../../data/models/responsemodel/doctor.dart';
import '../../repositories/doctor_repository.dart';

class GetDoctorByIdUseCase {
  final DoctorRepository repository;

  GetDoctorByIdUseCase(this.repository);

  Future<GetDoctorResponse> call(String doctorId) {
    return repository.getDoctorById(doctorId);
  }
}
