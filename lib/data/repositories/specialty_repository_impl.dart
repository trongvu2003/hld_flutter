import 'package:hld_flutter/domain/repositories/specialty_repository.dart';
import '../datasources/services/specialty_service.dart';
import '../models/responsemodel/specialty.dart';

class SpecialtyRepositoryImpl implements SpecialtyRepository {
  final SpecialtyService specialtyService;

  SpecialtyRepositoryImpl(this.specialtyService);

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
