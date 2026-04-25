import 'package:flutter/material.dart';
import '../../data/models/responsemodel/review_response.dart';
import '../../data/repositories/review_repository_impl.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewRepository repository;

  ReviewViewModel(this.repository);

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
      final res = await repository.getReviewsByDoctor(doctorId);
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
