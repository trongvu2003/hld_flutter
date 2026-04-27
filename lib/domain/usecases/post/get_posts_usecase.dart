import '../../../data/models/responsemodel/post.dart';
import '../../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  Future<PostPageResponse> call({required int skip, required int limit}) {
    return repository.fetchPosts(skip: skip, limit: limit);
  }
}
