import 'package:flutter/cupertino.dart';
import 'package:hld_flutter/models/responsemodel/specialty.dart';
import 'package:hld_flutter/repositories/specialty_repository.dart';

class SpecialtyViewModel extends ChangeNotifier {
  final SpecialtyRepository repository;

  SpecialtyViewModel(this.repository);

  List<GetSpecialtyResponse> specialties = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchSpecialties() async {
    if (specialties.isNotEmpty) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      specialties = await repository.getAllSpecialties();
      print("Thành công: ${specialties.length}");
    } catch (e) {
      error = e.toString();
      print("Lỗi: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}