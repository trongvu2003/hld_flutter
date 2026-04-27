import '../../../data/models/requestmodel/post.dart';
import '../../../data/models/responsemodel/post.dart';
import '../../repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  Future<CreatePostResponse> call(CreatePostRequest request) {
    return repository.createPost(request);
  }
}
