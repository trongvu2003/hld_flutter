import '../models/responsemodel/specialty.dart';
import '../services/specialty_service.dart';

class SpecialtyRepository {
  final SpecialtyService specialtyService;

  SpecialtyRepository(this.specialtyService);

  Future<List<GetSpecialtyResponse>> getAllSpecialties() {
    return specialtyService.getAllSpecialties();
  }
}
