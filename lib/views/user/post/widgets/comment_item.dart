import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hld_flutter/theme/app_colors.dart';
import '../../../../models/responsemodel/post.dart';
import 'comment_menu.dart';

class CommentItem extends StatelessWidget {
  final CommentPostResponse comment;
  final bool isOwner;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CommentItem({
    required this.comment,
    required this.isOwner,
    required this.isEditing,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            isEditing
                ? Colors.grey
                : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        border:
            isEditing
                ? Border.all(color: AppColors.lightTheme.withOpacity(0.3))
                : null,
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage:
                (comment.user.avatarURL?.isNotEmpty ?? false)
                    ? NetworkImage(comment.user.avatarURL!)
                    : null,
            child:
                (comment.user.avatarURL == null)
                    ? const Icon(Icons.person)
                    : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(comment.content, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          if (isOwner) CommentMenu(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}
