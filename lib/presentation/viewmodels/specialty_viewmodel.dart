import 'package:flutter/cupertino.dart';
import '../../data/models/responsemodel/doctor.dart';
import '../../data/models/responsemodel/specialty.dart';
import '../../domain/usecases/specialty/get_specialties_usecase.dart';
import '../../domain/usecases/specialty/get_specialty_by_id_usecase.dart';
import '../../domain/usecases/specialty/get_specialty_by_name_usecase.dart';

class SpecialtyViewModel extends ChangeNotifier {
  final GetSpecialtiesUseCase getSpecialtiesUseCase;
  final GetSpecialtyByIdUseCase getSpecialtyByIdUseCase;
  final GetSpecialtyByNameUseCase getSpecialtyByNameUseCase;

  SpecialtyViewModel({
    required this.getSpecialtiesUseCase,
    required this.getSpecialtyByIdUseCase,
    required this.getSpecialtyByNameUseCase,
  });

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
      specialties = await getSpecialtiesUseCase();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSpecialtyDoctor(String specialtyId) async {
    if (specialtyId.isEmpty) return;

    _setLoading(true);
    try {
      final result = await getSpecialtyByIdUseCase(specialtyId);

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
      final result = await getSpecialtyByNameUseCase(name);

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
      filteredDoctors =
          doctors.where((d) {
            return d.address?.toLowerCase().contains(location.toLowerCase()) ==
                true;
          }).toList();
    }
    notifyListeners();
  }
}
