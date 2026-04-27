import '../../../../data/models/requestmodel/post.dart';
import '../../../repositories/post_repository.dart';

class UpdateCommentUseCase {
  final PostRepository repository;

  UpdateCommentUseCase(this.repository);

  Future<void> call(String commentId, CreateCommentPostRequest request) {
    return repository.updateCommentById(commentId, request);
  }
}
