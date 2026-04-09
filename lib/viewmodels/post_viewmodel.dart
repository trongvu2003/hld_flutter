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
}
