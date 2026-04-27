import '../../../data/models/responsemodel/post.dart';
import '../../repositories/post_repository.dart';

class GetSimilarPostsUseCase {
  final PostRepository repository;

  GetSimilarPostsUseCase(this.repository);

  Future<List<SimilarPostResponse>> call({
    required String postId,
    int limit = 5,
    double minSimilarity = 0.6,
  }) {
    return repository.getSimilarPosts(
      postId: postId,
      limit: limit,
      minSimilarity: minSimilarity,
    );
  }
}