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

  Future<PostPageResponse> fetchPostsbyUserId({
    required userId,
    required int skip,
    required int limit,
  }) async {
    return await postService.getPostByUserId(userId, skip, limit);
  }

  Future<GetCommentPageResponse> getCommentByPostId(
    String postId,
    int skip,
    int limit,
  ) async {
    return await postService.getCommentByPostId(postId, skip, limit);
  }
}
