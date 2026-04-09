import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../viewmodels/post_viewmodel.dart';
import '../../../../skeleton/post_skeleton.dart';
import '../../widgets/post_card.dart';

class PostsTab extends StatefulWidget {
  final String userID;
  final String currentUserId;

  const PostsTab({
    super.key,
    required this.userID,
    required this.currentUserId,
  });

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostViewModel>().getPostByUserId(
        userId: widget.userID,
        skip: 0,
        limit: 10,
        append: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostViewModel>(
      builder: (context, vm, child) {
        if (vm.isUserPostsLoading && vm.userPosts.isEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: 3,
            itemBuilder: (context, index) => const PostSkeleton(),
          );
        }

        if (vm.userPosts.isEmpty) {
          final emptyMessage =
              (widget.userID == widget.currentUserId)
                  ? "Bạn chưa có bài viết nào."
                  : "Người dùng này chưa có bài viết nào.";

          return Center(
            child: Text(emptyMessage, style: const TextStyle(fontSize: 16)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8.0),
          itemCount: vm.userPosts.length,
          itemBuilder: (context, i) {
            final post = vm.userPosts[i];

            return PostCard(
              post: {
                'id': post.id,
                'content': post.content,
                'media': post.media,
                'userInfo':
                    post.userInfo != null
                        ? {
                          '_id': post.userInfo!.id,
                          'name': post.userInfo!.name,
                          'avatarURL': post.userInfo!.avatarUrl,
                        }
                        : null,
                'createdAt': post.createdAt,
              },
              currentUserId: widget.currentUserId,

              onReport: () {
                print("Báo cáo bài viết: ${post.id}");
              },
              onDelete: () {
                print("Xoá bài viết: ${post.id}");
              },
              onNavigateToDetail: () {
                Navigator.pushNamed(context, '/post-detail/${post.id}');
              },
            );
          },
        );
      },
    );
  }
}
