import 'package:flutter/cupertino.dart';
import 'package:hld_flutter/models/responsemodel/specialty.dart';
import 'package:hld_flutter/repositories/specialty_repository.dart';

import '../models/responsemodel/doctor.dart';

class SpecialtyViewModel extends ChangeNotifier {
  final SpecialtyRepository repository;

  SpecialtyViewModel(this.repository);

  List<GetSpecialtyResponse> specialties = [];
  List<Doctor> doctors = [];
  List<Doctor> filteredDoctors = [];

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  GetSpecialtyResponse? selectedSpecialty;
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

  Future<void> fetchSpecialtyDoctor(String specialtyId) async {
    if (specialtyId.isEmpty) return;

    _setLoading(true);
    try {
      final result = await repository.getSpecialtyById(specialtyId);

      selectedSpecialty = result;
      doctors = result.doctors;
      filteredDoctors = result.doctors;
      error = null;
    } catch (e) {
      error = e.toString();
      doctors = [];
      filteredDoctors = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchSpecialtyByName(String name) async {
    if (name.isEmpty) return;

    _setLoading(true);
    try {
      final result = await repository.getSpecialtyByName(name);

      selectedSpecialty = result;
      doctors = result.doctors;
      filteredDoctors = result.doctors;
      error = null;
    } catch (e) {
      selectedSpecialty = null;
      doctors = [];
      filteredDoctors = [];
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void filterDoctorsByLocation(String location) {
    if (location.isEmpty) {
      filteredDoctors = List.from(doctors);
    } else {
      filteredDoctors = doctors.where((d) {
        return d.address?.toLowerCase().contains(location.toLowerCase()) == true;
      }).toList();
    }
    notifyListeners();
  }

}