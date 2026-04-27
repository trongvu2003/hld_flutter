import '../../repositories/post_repository.dart';
import '../../../data/models/responsemodel/post.dart';

class GetPostsByUserUseCase {
  final PostRepository repository;

  GetPostsByUserUseCase(this.repository);

  Future<PostPageResponse> call({
    required String userId,
    required int skip,
    required int limit,
  }) {
    return repository.fetchPostsbyUserId(
      userId: userId,
      skip: skip,
      limit: limit,
    );
  }
}
