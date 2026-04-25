import '../../domain/repositories/review_repository.dart';
import '../datasources/services/review_service.dart';
import '../models/responsemodel/review_response.dart';

class ReViewRepositoryImpl implements ReViewRepository {
  final ReviewService service;

  ReViewRepositoryImpl(this.service);

  Future<List<ReviewResponse>> getReviewsByDoctor(String doctorId) async {
    return service.getReviewsByDoctor(doctorId);
  }
}
