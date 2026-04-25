import '../../data/models/responsemodel/specialty.dart';

abstract class SpecialtyRepository {
  Future<List<GetSpecialtyResponse>> getAllSpecialties();

  Future<GetSpecialtyResponse> getSpecialtyById(String specialtyId);

  Future<GetSpecialtyResponse> getSpecialtyByName(String name);
}
