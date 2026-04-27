import '../../repositories/review_repository.dart';
import '../../../data/models/responsemodel/review_response.dart';

class GetReviewsByDoctorUseCase {
  final ReViewRepository repository;

  GetReviewsByDoctorUseCase(this.repository);

  Future<List<ReviewResponse>> call(String doctorId) {
    return repository.getReviewsByDoctor(doctorId);
  }
}
