import '../../repositories/post_repository.dart';
import '../../../data/models/responsemodel/post.dart';

class GetPostByIdUseCase {
  final PostRepository repository;

  GetPostByIdUseCase(this.repository);

  Future<PostResponse> call(String postId) {
    return repository.getPostById(postId);
  }
}
