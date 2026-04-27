import '../../../../data/models/requestmodel/post.dart';
import '../../../../data/models/responsemodel/post.dart';
import '../../../repositories/post_repository.dart';

class CreateCommentUseCase {
  final PostRepository repository;

  CreateCommentUseCase(this.repository);

  Future<CreateCommentPostResponse> call(
    String postId,
    CreateCommentPostRequest request,
  ) {
    return repository.createCommentByPostId(postId, request);
  }
}
