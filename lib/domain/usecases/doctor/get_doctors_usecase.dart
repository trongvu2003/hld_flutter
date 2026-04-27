import '../../repositories/doctor_repository.dart';
import '../../../data/models/responsemodel/doctor.dart';

class GetDoctorsUseCase {
  final DoctorRepository repository;

  GetDoctorsUseCase(this.repository);

  Future<List<GetDoctorResponse>> call() {
    return repository.getDoctors();
  }
}
