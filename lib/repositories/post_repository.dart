import '../models/requestmodel/post.dart';
import '../models/responsemodel/post.dart';
import '../services/post_service.dart';

class PostRepository {
  final PostService postService;

  PostRepository(this.postService);

  Future<PostPageResponse> fetchPosts({
    required int skip,
    required int limit,
  }) async {
    return await postService.getAllPosts(skip, limit);
  }

  Future<CreatePostResponse> createPost(CreatePostRequest request) async {
    return await postService.createPost(request);
  }
}
