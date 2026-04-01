import 'package:hld_flutter/services/review_service.dart';
import '../models/responsemodel/review_response.dart';

class ReviewRepository {
  final ReviewService service;

  ReviewRepository(this.service);

  Future<List<ReviewResponse>> getReviewsByDoctor(String doctorId) async {
    return service.getReviewsByDoctor(doctorId);
  }
}
