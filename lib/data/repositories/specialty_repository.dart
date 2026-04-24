import '../datasources/services/specialty_service.dart';
import '../models/responsemodel/specialty.dart';

class SpecialtyRepository {
  final SpecialtyService specialtyService;

  SpecialtyRepository(this.specialtyService);

  Future<List<GetSpecialtyResponse>> getAllSpecialties() {
    return specialtyService.getAllSpecialties();
  }

  Future<GetSpecialtyResponse> getSpecialtyById(String specialtyId) {
    return specialtyService.getSpecialtyById(specialtyId);
  }

  Future<GetSpecialtyResponse> getSpecialtyByName(String name) {
    return specialtyService.getSpecialtyByName(name);
  }
}
