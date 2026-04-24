import 'package:flutter/material.dart';
import 'package:hld_flutter/presentation/views/user/home/post/widgets/comment_item.dart';
import 'package:hld_flutter/routes/app_routes.dart';
import 'package:hld_flutter/presentation/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/responsemodel/post.dart';
import '../../../../../data/models/responsemodel/user_response.dart';
import '../../../../viewmodels/post_viewmodel.dart';
import '../../../../viewmodels/user_viewmodel.dart';
import '../../../skeleton/post_skeleton.dart';
import '../../../skeleton/skeleton_box.dart';
import '../widgets/post_card.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final postVM = context.read<PostViewModel>();
      final userVM = context.read<UserViewModel>();

      userVM.loadCurrentUser();

      if (widget.postId.isNotEmpty) {
        postVM.getPostById(widget.postId);
        postVM.getSimilarPosts(widget.postId);
      }
      context.read<PostViewModel>().fetchComments(
        postId: widget.postId,
        skip: 0,
        limit: 10,
      );
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final postVM = context.watch<PostViewModel>();

    final currentUser = userVM.currentUser;
    final post = postVM.postDetail;
    final similarPosts = postVM.similarPosts;

    if (post != null && currentUser != null) {
      return Scaffold(
        appBar: const HeadbarDetailPost(),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  children: [
                    PostCard(
                      post: post,
                      currentUserId: currentUser.id ?? "",
                      onReport: () => print("Báo cáo: ${post.id}"),
                      onDelete: () => print("Xoá: ${post.id}"),
                      onNavigateToDetail: () {},
                      onEdit: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.createpost,
                          arguments: {
                            'postId': post.id,
                            'userId': userVM.currentUser?.id,
                            'userRole': userVM.currentUser?.role,
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    //BÀI VIẾT LIÊN QUAN
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SimilarPostsWidget(similarPosts: similarPosts),
                    ),

                    const SizedBox(height: 10),
                    const Divider(thickness: 3, color: Color(0xFFF0F2F5)),

                    Builder(
                      builder: (context) {
                        final comments = postVM.getComments(widget.postId);
                        final isCommentsLoading = postVM.getIsLoadingComments(
                          widget.postId,
                        );
                        if (isCommentsLoading && comments.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (comments.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Center(
                              child: Text(
                                "Chưa có bình luận nào. Hãy là người đầu tiên!",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        } else {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              // Kiểm tra xem bình luận này có phải của người đang đăng nhập không
                              final isOwner = currentUser.id == comment.user.id;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 6.0,
                                ),
                                child: CommentItem(
                                  comment: comment,
                                  isOwner: isOwner,
                                  isEditing: false,
                                  onEdit: () {
                                    print("Chỉnh sửa bình luận: ${comment.id}");
                                  },
                                  onDelete: () {
                                    print("Xoá bình luận: ${comment.id}");
                                    // Gọi API xoá từ postVM
                                    context.read<PostViewModel>().deleteComment(
                                      postId: widget.postId,
                                      commentId: comment.id,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              //  PHẦN NHẬP BÌNH LUẬN
              _buildCommentInputArea(context, currentUser),
            ],
          ),
        ),
      );
    } else {
      // GIAO DIỆN SKELETON LÚC MỚI BẤM VÀO
      return Scaffold(
        appBar: const HeadbarDetailPost(),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            children: const [
              PostSkeleton(),
              SizedBox(height: 16),
              Skeleton(width: 150, height: 24, radius: 4),
              SizedBox(height: 12),
              Row(
                children: [
                  Skeleton(width: 160, height: 40, radius: 8),
                  SizedBox(width: 8),
                  Skeleton(width: 160, height: 40, radius: 8),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  // Khung nhập bình luận ghim ở đáy
  Widget _buildCommentInputArea(BuildContext context, User currentUser) {
    final user = context.read<UserViewModel>().currentUser;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar của bạn
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade300,
            backgroundImage:
                (currentUser.avatarURL != null &&
                        currentUser.avatarURL!.isNotEmpty)
                    ? NetworkImage(currentUser.avatarURL!)
                    : const AssetImage('assets/images/avatar_doctor.jpg')
                        as ImageProvider,
          ),
          const SizedBox(width: 12),

          // Ô nhập văn bản
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Viết bình luận...",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),

          // Nút Gửi
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.lightTheme),
            onPressed: () {
              if (_commentController.text.trim().isNotEmpty) {
                print("Gửi bình luận: ${_commentController.text}");
                context.read<PostViewModel>().sendComment(
                  postId: widget.postId,
                  userId: user?.id ?? '',
                  userModel: user?.role ?? '',
                  content: _commentController.text,
                );
                _commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

// WIDGET BÀI VIẾT LIÊN QUAN
class SimilarPostsWidget extends StatelessWidget {
  final List<PostResponse> similarPosts;

  const SimilarPostsWidget({Key? key, required this.similarPosts})
    : super(key: key);

  String _shortenSentence(String sentence, int maxLength) {
    if (sentence.length > maxLength) {
      return "${sentence.substring(0, maxLength)}...";
    }
    return sentence;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bài viết liên quan",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (similarPosts.isEmpty)
          Row(
            children: [
              _buildSkeletonBox(),
              const SizedBox(width: 8),
              _buildSkeletonBox(),
            ],
          )
        else
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: similarPosts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final similarPost = similarPosts[index];
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.postdetail,
                      arguments: {'postId': similarPost.id},
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _shortenSentence(similarPost.content, 30),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSkeletonBox() {
    return const Skeleton(width: 160, height: 40, radius: 8);
  }
}

class HeadbarDetailPost extends StatelessWidget implements PreferredSizeWidget {
  const HeadbarDetailPost({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: AppColors.lightTheme,
      centerTitle: true,
      title: Text(
        "Bài viết chi tiết",
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: Colors.black,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 2,
      shadowColor: Colors.black26,
    );
  }
}
