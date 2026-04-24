import '../datasources/services/post_service.dart';
import '../models/requestmodel/post.dart';
import '../models/responsemodel/post.dart';


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

  Future<CreateCommentPostResponse> createCommentByPostId(
    String postId,
    CreateCommentPostRequest request,
  ) async {
    return await postService.createCommentByPostId(postId, request);
  }

  Future<void> updateCommentById(
    String commentId,
    CreateCommentPostRequest request,
  ) async {
    return await postService.updateCommentById(commentId, request);
  }

  Future<void> deleteCommentById(String commentId) async {
    return await postService.deleteCommentById(commentId);
  }

  Future<PostResponse> getPostById(String postId) async {
    return await postService.getPostById(postId);
  }

  Future<List<SimilarPostResponse>> getSimilarPosts({
    required postId,
    required int limit,
    required double minSimilarity,
  }) {
    return postService.getSimilarPosts(
      postId: postId,
      limit: limit,
      minSimilarity: minSimilarity,
    );
  }

  Future<void> deletePostById(String postId) async {
    return await postService.deletePostById(postId);
  }

  Future<void> updatePost({
    required String postId,
    String? content,
    List<String>? mediaPaths,
    List<String>? imagePaths,
  }) async {
    return await postService.updatePost(
      postId: postId,
      content: content,
      mediaPaths: mediaPaths,
      imagePaths: imagePaths,
    );
  }
}
