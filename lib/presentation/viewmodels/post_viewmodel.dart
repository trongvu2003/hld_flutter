import 'package:flutter/material.dart';
import '../../data/models/requestmodel/post.dart';
import '../../data/models/responsemodel/post.dart';
import '../../domain/usecases/post/comment/create_comment_usecase.dart';
import '../../domain/usecases/post/comment/delete_comment_usecase.dart';
import '../../domain/usecases/post/comment/get_comments_usecase.dart';
import '../../domain/usecases/post/comment/update_comment_usecase.dart';
import '../../domain/usecases/post/create_post_usecase.dart';
import '../../domain/usecases/post/delete_post_usecase.dart';
import '../../domain/usecases/post/get_post_by_id_usecase.dart';
import '../../domain/usecases/post/get_posts_by_user_usecase.dart';
import '../../domain/usecases/post/get_posts_usecase.dart';
import '../../domain/usecases/post/get_similar_posts_usecase.dart';
import '../../domain/usecases/post/update_post_usecase.dart';

class PostViewModel extends ChangeNotifier {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final DeletePostUseCase deletePostUseCase;
  final UpdatePostUseCase updatePostUseCase;
  final GetPostByIdUseCase getPostByIdUseCase;
  final GetSimilarPostsUseCase getSimilarPostsUseCase;
  final GetPostsByUserUseCase getPostsByUserUseCase;
  final GetCommentsUseCase getCommentsUseCase;
  final CreateCommentUseCase createCommentUseCase;
  final UpdateCommentUseCase updateCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;

  PostViewModel({
    required this.getPostsUseCase,
    required this.createPostUseCase,
    required this.deletePostUseCase,
    required this.updatePostUseCase,
    required this.getPostByIdUseCase,
    required this.getSimilarPostsUseCase,
    required this.getPostsByUserUseCase,
    required this.getCommentsUseCase,
    required this.createCommentUseCase,
    required this.updateCommentUseCase,
    required this.deleteCommentUseCase,
  });

  List<PostResponse> posts = [];
  bool isLoading = false;
  bool isError = false;
  bool hasMore = true;
  bool isLoadingMore = false;
  String error = '';

  bool isCreating = false;
  bool isCreateSuccess = false;
  String createError = '';
  String _errorMessage = '';

  String get errorMessage => _errorMessage;
  String _successMessage = '';

  String get successMessage => _successMessage;
  double _uploadProgress = 0;

  double get uploadProgress => _uploadProgress;

  // CÁC BIẾN CHO FETCH BY ID
  List<PostResponse> userPosts = [];
  bool isUserPostsLoading = false;
  bool hasMoreUserPosts = true;

  //  Danh sách bài viết cho trang Profile của TÔI
  List<PostResponse> myPosts = [];
  bool isMyPostsLoading = false;

  //  Danh sách bài viết cho trang NGƯỜI KHÁC (Bác sĩ)
  List<PostResponse> visitorPosts = [];
  bool isVisitorPostsLoading = false;

  //QUẢN LÝ BÌNH LUẬN THEO MAP
  Map<String, List<CommentPostResponse>> commentsMap = {};
  Map<String, bool> hasMoreMap = {};
  Map<String, bool> isLoadingMap = {};

  List<CommentPostResponse> getComments(String postId) =>
      commentsMap[postId] ?? [];

  bool getHasMoreComments(String postId) => hasMoreMap[postId] ?? false;

  bool getIsLoadingComments(String postId) => isLoadingMap[postId] ?? false;
  PostResponse? postDetail;
  bool isPostDetailLoading = false;
  List<PostResponse> similarPosts = [];
  bool isSimilarLoading = false;

  Future<void> fetchPosts({bool forceRefresh = false}) async {
    if (!forceRefresh && posts.isNotEmpty) return;

    isLoading = true;
    isError = false;
    // Nếu forceRefresh = true, ta clear danh sách cũ trước
    if (forceRefresh) {
      posts.clear();
      hasMore = true;
    }
    notifyListeners();

    try {
      final res = await getPostsUseCase(skip: 0, limit: 10);

      posts = res.posts;
      hasMore = res.hasMore;
    } catch (e) {
      error = e.toString();
      isError = true;
    }

    isLoading = false;
    notifyListeners();
  }

  // Load thêm
  Future<void> loadMorePosts() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final res = await getPostsUseCase(skip: posts.length, limit: 10);

      posts.addAll(res.posts);
      hasMore = res.hasMore;
    } catch (e) {
      debugPrint("Load more error: $e");
    }

    isLoadingMore = false;
    notifyListeners();
  }

  // Tạo bài viết
  Future<void> createPost(CreatePostRequest request) async {
    isCreating = true;
    isCreateSuccess = false;
    createError = '';
    notifyListeners();

    try {
      await createPostUseCase(request);
      await fetchPosts(forceRefresh: true);
      isCreating = false;
      isCreateSuccess = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 2500));

      isCreateSuccess = false;
      notifyListeners();
    } catch (e) {
      createError = e.toString();
      isCreateSuccess = false;
      isCreating = false;
      notifyListeners();
    }
  }

  Future<void> getPostByUserId({
    required String userId,
    required bool isMyProfile,
    int skip = 0,
    int limit = 10,
  }) async {
    if (isMyProfile) {
      isMyPostsLoading = true;
      myPosts = []; // Clear bài cũ của mình
    } else {
      isVisitorPostsLoading = true;
      visitorPosts = []; // Clear bài cũ của bác sĩ cũ
    }
    notifyListeners();

    try {
      final response = await getPostsByUserUseCase(
        userId: userId,
        skip: skip,
        limit: limit,
      );

      if (isMyProfile) {
        myPosts = response.posts;
      } else {
        visitorPosts = response.posts;
      }
    } catch (e) {
      debugPrint("Lỗi: $e");
    } finally {
      isMyPostsLoading = false;
      isVisitorPostsLoading = false;
      notifyListeners();
    }
  }

  Future<GetCommentPageResponse> fetchComments({
    required String postId,
    int skip = 0,
    int limit = 10,
  }) async {
    isLoadingMap[postId] = true;
    notifyListeners();

    try {
      final res = await getCommentsUseCase(postId, skip, limit);
      if (skip == 0) {
        commentsMap[postId] = res.comments;
      } else {
        final currentComments = commentsMap[postId] ?? [];
        commentsMap[postId] = [...currentComments, ...res.comments];
      }
      hasMoreMap[postId] = res.hasMore;
      return res;
    } catch (e) {
      debugPrint("Error fetching comments for post $postId: $e");
      rethrow;
    } finally {
      isLoadingMap[postId] = false;
      notifyListeners();
    }
  }

  Future<CreateCommentPostResponse> sendComment({
    required String postId,
    required String userId,
    required String userModel,
    required String content,
  }) async {
    try {
      final request = CreateCommentPostRequest(
        userId: userId,
        userModel: userModel,
        content: content,
      );

      final response = await createCommentUseCase(postId, request);
      //  Làm mới lại danh sách bình luận của bài viết này
      await fetchComments(postId: postId, skip: 0, limit: 10);
      return response;
    } catch (e) {
      debugPrint("Error sending comment: $e");
      rethrow;
    }
  }

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String userId,
    required String userModel,
    required String content,
  }) async {
    try {
      final request = CreateCommentPostRequest(
        userId: userId,
        userModel: userModel,
        content: content,
      );

      await updateCommentUseCase(commentId, request);
      await fetchComments(postId: postId, skip: 0, limit: 10);
    } catch (e) {
      debugPrint("Error updating comment: $e");
      rethrow;
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await deleteCommentUseCase(commentId);
      final commentsOfThisPost = commentsMap[postId];
      if (commentsOfThisPost != null) {
        commentsOfThisPost.removeWhere((c) => c.id == commentId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error deleting comment: $e");
      rethrow;
    }
  }

  Future<void> getPostById(String postId) async {
    isPostDetailLoading = true;
    postDetail = null;
    notifyListeners();

    try {
      final res = await getPostByIdUseCase(postId);

      postDetail = res;
      print("Lấy bài viết chi tiết thành công: ${res.id}");
    } catch (e) {
      debugPrint("Lỗi khi lấy chi tiết bài viết: $e");
    } finally {
      isPostDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> getSimilarPosts(String postId) async {
    isSimilarLoading = true;
    similarPosts = [];
    notifyListeners();

    try {
      final response = await getSimilarPostsUseCase(
        postId: postId,
        limit: 5,
        minSimilarity: 0.6,
      );

      similarPosts = response.map((item) => item.post).toList();
    } catch (e) {
      debugPrint("Lỗi lấy bài viết liên quan: $e");
    } finally {
      isSimilarLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await deletePostUseCase(postId);
      //Xoá bài viết khỏi danh sách bản tin chung
      posts.removeWhere((post) => post.id == postId);
      // Xoá khỏi các danh sách trang cá nhân (nếu có)
      myPosts.removeWhere((post) => post.id == postId);
      visitorPosts.removeWhere((post) => post.id == postId);
      similarPosts.removeWhere((post) => post.id == postId);

      // Nếu bài viết đang xem chi tiết chính là bài vừa bị xoá thì clear data
      if (postDetail?.id == postId) {
        postDetail = null;
      }

      //  Dọn dẹp luôn danh sách bình luận của bài viết này cho nhẹ bộ nhớ
      commentsMap.remove(postId);
      hasMoreMap.remove(postId);
      isLoadingMap.remove(postId);

      _successMessage = 'Xoá bài viết thành công';

      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi khi xoá bài viết: $e");
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  bool isUpdating = false;

  Future<void> updatePost(String postId, CreatePostRequest request) async {
    isUpdating = true;
    notifyListeners();

    try {
      List<String> videoPaths = [];
      List<String> imagePaths = [];

      if (request.mediaPaths != null) {
        for (var path in request.mediaPaths!) {
          final ext = path.toLowerCase().split('.').last;

          if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
            videoPaths.add(path);
          } else {
            imagePaths.add(path);
          }
        }
      }

      await updatePostUseCase(
        postId: postId,
        content: request.content,
        mediaPaths: videoPaths.isNotEmpty ? videoPaths : null,
        imagePaths: imagePaths.isNotEmpty ? imagePaths : null,
      );
      await fetchPosts(forceRefresh: true);
    } catch (e) {
      debugPrint("Lỗi update post: $e");
      rethrow;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  void clearPosts() {
    posts.clear();
    hasMore = true;
    myPosts.clear();
    visitorPosts.clear();
    notifyListeners();
  }
}
