import '../../../data/models/responsemodel/specialty.dart';
import '../../repositories/specialty_repository.dart';

class GetSpecialtiesUseCase {
  final SpecialtyRepository repository;

  GetSpecialtiesUseCase(this.repository);

  Future<List<GetSpecialtyResponse>> call() {
    return repository.getAllSpecialties();
  }
}
