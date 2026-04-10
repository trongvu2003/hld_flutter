import 'package:flutter/material.dart';
import 'package:hld_flutter/theme/app_colors.dart';
import 'package:hld_flutter/views/user/post/widgets/comment_item.dart';
import 'package:provider/provider.dart';
import '../../../models/responsemodel/post.dart';
import '../../../viewmodels/post_viewmodel.dart';
import '../../../viewmodels/user_viewmodel.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId;
  final String currentUserId;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    required this.currentUserId,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _editingCommentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostViewModel>().fetchComments(
        postId: widget.postId,
        skip: 0,
        limit: 10,
      );
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    final viewModel = context.read<PostViewModel>();
    final isLoading = viewModel.isLoadingMap[widget.postId] ?? false;
    final hasMore = viewModel.hasMoreMap[widget.postId] ?? false;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoading &&
        hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final viewModel = context.read<PostViewModel>();
    final currentLength = viewModel.commentsMap[widget.postId]?.length ?? 0;

    await viewModel.fetchComments(
      postId: widget.postId,
      skip: currentLength,
      limit: 10,
    );
  }

  void _submitComment() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    // Ví dụ:
    // if (_editingCommentId != null) {
    //    await context.read<PostViewModel>().updateComment(widget.postId, _editingCommentId!, text);
    // } else {
    //    await context.read<PostViewModel>().addComment(widget.postId, text);
    // }

    _textController.clear();
    _editingCommentId = null;
    _focusNode.unfocus();

    // Cuộn lên đầu để xem comment mới (nếu add mới)
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _startEdit(CommentPostResponse comment) {
    setState(() {
      _editingCommentId = comment.id;
      _textController.text = comment.content;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Consumer<PostViewModel>(
      builder: (context, viewModel, child) {
        final comments = viewModel.commentsMap[widget.postId] ?? [];
        final isLoading = viewModel.isLoadingMap[widget.postId] ?? false;
        final hasMore = viewModel.hasMoreMap[widget.postId] ?? false;

        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          snap: true,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  _DragHandle(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: _CommentInput(
                      controller: _textController,
                      focusNode: _focusNode,
                      isEditing: _editingCommentId != null,
                      onSubmit: _submitComment,
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF3F4F6),
                  ),

                  Expanded(
                    child:
                        (isLoading && comments.isEmpty)
                            ? const Center(child: CircularProgressIndicator())
                            : comments.isEmpty
                            ? _EmptyComments()
                            : ListView.builder(
                              controller: scrollController,
                              padding: EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                8 + bottomInset,
                              ),
                              itemCount: comments.length + 1,
                              itemBuilder: (context, index) {
                                if (index == comments.length) {
                                  return _ListFooter(
                                    isLoadingMore: isLoading,
                                    hasMore: hasMore,
                                  );
                                }
                                final comment = comments[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: CommentItem(
                                    comment: comment,
                                    isOwner:
                                        comment.user.id == widget.currentUserId,
                                    isEditing: _editingCommentId == comment.id,
                                    onEdit: () => _startEdit(comment),
                                    onDelete: () {
                                      // TODO: Gọi hàm xóa từ ViewModel
                                      // viewModel.deleteComment(widget.postId, comment.id);
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _EmptyComments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có bình luận nào',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'Hãy là người đầu tiên bình luận!',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasMore;

  const _ListFooter({required this.isLoadingMore, required this.hasMore});

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore && hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 40, height: 1, color: Colors.grey.shade300),
          const SizedBox(width: 8),
          Text(
            'Đã hết bình luận',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
          const SizedBox(width: 8),
          Container(width: 40, height: 1, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEditing;
  final VoidCallback onSubmit;

  const _CommentInput({
    required this.controller,
    required this.focusNode,
    required this.isEditing,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();
    final user = vm.user;
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.lightTheme),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundImage:
                (user?.avatarURL != null && user!.avatarURL!.isNotEmpty)
                    ? NetworkImage(user.avatarURL!)
                    : null,
          ),
        ),
        const SizedBox(width: 10),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.lightTheme.withOpacity(0.7)),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Nhập bình luận...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Send button
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final hasText = controller.text.trim().isNotEmpty;
            return AnimatedScale(
              scale: hasText ? 1.0 : 0.85,
              duration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTap: hasText ? onSubmit : null,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color:
                        hasText ? AppColors.lightTheme : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEditing ? Icons.check_rounded : Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
