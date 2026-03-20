
// ═══════════════════════════════════════════════════════════════
// POST CARD - tương đương Post() composable
// ═══════════════════════════════════════════════════════════════
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final String currentUserId;
  final VoidCallback onReport;
  final VoidCallback onDelete;
  final VoidCallback onNavigateToDetail;

  const PostCard({
    required this.post,
    required this.currentUserId,
    required this.onReport,
    required this.onDelete,
    required this.onNavigateToDetail,
  });

  @override
  Widget build(BuildContext context) {
    final userInfo = post['userInfo'] as Map? ?? {};
    final images = post['images'] as List? ?? [];
    final isOwner = currentUserId == userInfo['id'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
            child: Row(
              children: [
                ClipOval(
                  child: Container(
                    width: 45,
                    height: 45,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userInfo['name'] ?? 'Người dùng',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        post['createdAt'] ?? '',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'report') onReport();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder:
                      (_) =>
                  isOwner
                      ? [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Xoá',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ]
                      : [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Báo cáo'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          if ((post['content'] ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(post['content']),
            ),

          // Images
          if (images.isNotEmpty) ...[
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: images.first.toString(),
                fit: BoxFit.cover,
                errorWidget:
                    (_, __, ___) => Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          ],

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                  iconSize: 22,
                ),
                Text('${post['likesCount'] ?? 0}'),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onNavigateToDetail,
                  icon: const Icon(Icons.comment_outlined),
                  iconSize: 22,
                ),
                Text('${post['commentsCount'] ?? 0}'),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}