import 'package:flutter/material.dart';
import '../models/responsemodel/post.dart';
import '../repositories/post_repository.dart';

class PostViewModel extends ChangeNotifier {
  final PostRepository repository;

  PostViewModel(this.repository);

  List<PostModel> posts = [];

  bool isLoading = false;
  bool isError = false;

  bool hasMore = true;
  bool isLoadingMore = false;

  String error = '';

  // Load lần đầu
  Future<void> fetchPosts() async {
    if (posts.isNotEmpty) return;

    isLoading = true;
    isError = false;
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
      final res = await repository.fetchPosts(
        skip: posts.length,
        limit: 10,
      );

      posts.addAll(res.posts);
      hasMore = res.hasMore;
    } catch (e) {
      debugPrint("Load more error: $e");
    }

    isLoadingMore = false;
    notifyListeners();
  }
}