import '../../../data/models/responsemodel/specialty.dart';
import '../../repositories/specialty_repository.dart';

class GetSpecialtyByIdUseCase {
  final SpecialtyRepository repository;

  GetSpecialtyByIdUseCase(this.repository);

  Future<GetSpecialtyResponse> call(String id) {
    return repository.getSpecialtyById(id);
  }
}
