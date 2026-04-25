import '../../data/models/requestmodel/post.dart';
import '../../data/models/responsemodel/post.dart';

abstract class PostRepository {
  Future<PostPageResponse> fetchPosts({required int skip, required int limit});

  Future<CreatePostResponse> createPost(CreatePostRequest request);

  Future<PostPageResponse> fetchPostsbyUserId({
    required String userId,
    required int skip,
    required int limit,
  });

  Future<GetCommentPageResponse> getCommentByPostId(
    String postId,
    int skip,
    int limit,
  );

  Future<CreateCommentPostResponse> createCommentByPostId(
    String postId,
    CreateCommentPostRequest request,
  );

  Future<void> updateCommentById(
    String commentId,
    CreateCommentPostRequest request,
  );

  Future<void> deleteCommentById(String commentId);

  Future<PostResponse> getPostById(String postId);

  Future<List<SimilarPostResponse>> getSimilarPosts({
    required String postId,
    required int limit,
    required double minSimilarity,
  });

  Future<void> deletePostById(String postId);

  Future<void> updatePost({
    required String postId,
    String? content,
    List<String>? mediaPaths,
    List<String>? imagePaths,
  });
}
