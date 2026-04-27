import '../../../../data/models/responsemodel/post.dart';
import '../../../repositories/post_repository.dart';

class GetCommentsUseCase {
  final PostRepository repository;

  GetCommentsUseCase(this.repository);

  Future<GetCommentPageResponse> call(String postId, int skip, int limit) {
    return repository.getCommentByPostId(postId, skip, limit);
  }
}
