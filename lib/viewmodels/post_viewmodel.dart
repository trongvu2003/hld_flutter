import 'package:flutter/material.dart';
import '../models/requestmodel/post.dart';
import '../models/responsemodel/post.dart';
import '../repositories/post_repository.dart';

class PostViewModel extends ChangeNotifier {
  final PostRepository repository;

  PostViewModel(this.repository);

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
      final res = await repository.fetchPosts(skip: 0, limit: 10);

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
      final res = await repository.fetchPosts(skip: posts.length, limit: 10);

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
      await repository.createPost(request);
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
      final response = await repository.fetchPostsbyUserId(
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
      final res = await repository.getCommentByPostId(postId, skip, limit);
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

      final response = await repository.createCommentByPostId(postId, request);
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

      await repository.updateCommentById(commentId, request);
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
      await repository.deleteCommentById(commentId);
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
      final res = await repository.getPostById(postId);

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
      final response = await repository.getSimilarPosts(
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

  void clearPosts() {
    posts.clear();
    hasMore = true;
    myPosts.clear();
    visitorPosts.clear();
    notifyListeners();
  }
}
