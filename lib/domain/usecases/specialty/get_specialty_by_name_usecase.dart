import '../../../data/models/responsemodel/specialty.dart';
import '../../repositories/specialty_repository.dart';

class GetSpecialtyByNameUseCase {
  final SpecialtyRepository repository;

  GetSpecialtyByNameUseCase(this.repository);

  Future<GetSpecialtyResponse> call(String name) {
    return repository.getSpecialtyByName(name);
  }
}
