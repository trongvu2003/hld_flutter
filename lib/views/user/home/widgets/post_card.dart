import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hld_flutter/views/user/home/widgets/video_thumbnail_only.dart';

import '../../../../theme/app_colors.dart';

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
    final images = post['media'] as List? ?? [];
    final isOwner = currentUserId == userInfo['id'];
    final avatar = userInfo['avatarURL'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white,
      child: Card(
        elevation: 2,
        borderOnForeground: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.lightTheme.withOpacity(0.8), // màu viền
            width: 1, // độ dày viền
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 45,
                      height: 45,
                      child:
                          avatar != null
                              ? CachedNetworkImage(
                                imageUrl: avatar,
                                fit: BoxFit.cover,
                              )
                              : Image.asset(
                                'assets/images/avatar_doctor.jpg',
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userInfo['name'] ?? 'Người dùng',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatTime(post['createdAt']),
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

            // Media (Hỗ trợ cả Ảnh và Video)
            if (images.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                // Lấy link media đầu tiên
                child: _buildMediaItem(images.first.toString(), context),
              ),
            ],

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border),
                          iconSize: 30,
                        ),
                        Text('${post['likesCount'] ?? 0}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: onNavigateToDetail,
                          icon: const Icon(Icons.comment_outlined),
                          iconSize: 30,
                        ),
                        Text('${post['commentsCount'] ?? 0}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaItem(String url, BuildContext context) {
    bool isVideo(String url) {
      final u = url.toLowerCase();
      return u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.avi');
    }

    if (isVideo(url)) {
      return VideoThumbnailOnly(videoUrl: url);
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      errorWidget:
          (_, __, ___) => Container(
            height: 200,
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Icon(Icons.broken_image),
          ),
    );
  }
}

String formatTime(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';

  final date = DateTime.parse(dateStr).toLocal();

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final day = twoDigits(date.day);
  final month = twoDigits(date.month);
  final year = date.year;

  final hour = twoDigits(date.hour);
  final minute = twoDigits(date.minute);

  return '$day/$month/$year $hour:$minute';
}
