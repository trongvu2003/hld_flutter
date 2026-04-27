import 'package:flutter/material.dart';
import '../../data/models/responsemodel/review_response.dart';
import '../../domain/usecases/review/get_reviews_by_doctor_usecase.dart';

class ReviewViewModel extends ChangeNotifier {
  final GetReviewsByDoctorUseCase getReviewsByDoctorUseCase;

  ReviewViewModel({
    required this.getReviewsByDoctorUseCase,
  });

  List<ReviewResponse> reviews = [];
  bool isLoading = false;
  bool isError = false;
  String error = '';
  bool isSubmitting =false;

  Future<void> fetchReviewsByDoctor(String doctorId) async {
    if (doctorId.isEmpty) return;

    isLoading = true;
    isError = false;
    error = '';
    reviews = [];
    notifyListeners();
    try {
      final res = await getReviewsByDoctorUseCase(doctorId);
      reviews = res;
    } catch (e) {
      isError = true;
      error = e.toString();
      print('LỖI FETCH REVIEW: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
