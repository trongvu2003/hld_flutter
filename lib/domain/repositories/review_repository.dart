import '../../data/models/responsemodel/review_response.dart';

abstract class ReViewRepository {
  Future<List<ReviewResponse>> getReviewsByDoctor(String doctorId);
}