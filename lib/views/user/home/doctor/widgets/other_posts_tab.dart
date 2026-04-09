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
    //  Xác định ngay là load cho mình hay cho bác sĩ
    final bool isMe = widget.userID == widget.currentUserId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostViewModel>().getPostByUserId(
        userId: widget.userID,
        skip: 0,
        limit: 10,
        isMyProfile: isMe,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = widget.userID == widget.currentUserId;
    return Consumer<PostViewModel>(
      builder: (context, vm, child) {
        // Lấy đúng data tương ứng từ ViewModel dựa trên isMe
        final posts = isMe ? vm.myPosts : vm.visitorPosts;
        final isLoading = isMe ? vm.isMyPostsLoading : vm.isVisitorPostsLoading;
        if (isLoading && posts.isEmpty) {
          return _buildSkeletonList();
        }
        if (posts.isEmpty) {
          final emptyMessage =
              isMe
                  ? "Bạn chưa có bài viết nào."
                  : "Người dùng này chưa có bài viết nào.";

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(emptyMessage, style: const TextStyle(fontSize: 16)),
            ),
          );
        }

        return _buildPostList(posts);
      },
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      itemCount: 3,
      itemBuilder: (context, index) => const PostSkeleton(),
    );
  }

  Widget _buildPostList(List<dynamic> posts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      itemCount: posts.length,
      itemBuilder: (context, i) {
        final post = posts[i];
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
          onReport: () => print("Báo cáo: ${post.id}"),
          onDelete: () => print("Xoá: ${post.id}"),
          onNavigateToDetail: () {
            Navigator.pushNamed(context, '/post-detail/${post.id}');
          },
        );
      },
    );
  }
}
