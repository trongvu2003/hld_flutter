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
        // Cần thêm clipBehavior để ảnh media không đè lên góc bo tròn của Card
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.lightTheme.withOpacity(0.8),
            width: 1,
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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatTime(post['createdAt']),
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Text(post['content']),
              ),

            // Media Grid (Hỗ trợ nhiều Ảnh và Video)
            if (images.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: _buildMediaGrid(images, context),
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

  // Bố cục lưới động tùy theo số lượng media
  Widget _buildMediaGrid(List images, BuildContext context) {
    int count = images.length;

    // 1 hình: Full width
    if (count == 1) {
      return SizedBox(
        height: 250,
        child: _buildMediaItem(images[0].toString(), context),
      );
    }

    // 2 hình: Chia đôi chiều ngang
    if (count == 2) {
      return SizedBox(
        height: 250,
        child: Row(
          children: [
            Expanded(child: _buildMediaItem(images[0].toString(), context)),
            const SizedBox(width: 2),
            Expanded(child: _buildMediaItem(images[1].toString(), context)),
          ],
        ),
      );
    }

    // 3 hình: 1 hình lớn bên trái, 2 hình nhỏ bên phải
    if (count == 3) {
      return SizedBox(
        height: 250,
        child: Row(
          children: [
            Expanded(child: _buildMediaItem(images[0].toString(), context)),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _buildMediaItem(images[1].toString(), context),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: _buildMediaItem(images[2].toString(), context),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 4 hình trở lên: Lưới 2x2. Nếu > 4 thì ô cuối hiện lớp phủ +N
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildMediaItem(images[0].toString(), context)),
                const SizedBox(width: 2),
                Expanded(child: _buildMediaItem(images[1].toString(), context)),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildMediaItem(images[2].toString(), context)),
                const SizedBox(width: 2),
                Expanded(
                  child: _buildMediaItem(
                    images[3].toString(),
                    context,
                    remainingCount: count > 4 ? count - 4 : 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Render từng item, có hỗ trợ lớp phủ +N cho hình cuối
  Widget _buildMediaItem(
    String url,
    BuildContext context, {
    int remainingCount = 0,
  }) {
    bool isVideo(String url) {
      final u = url.toLowerCase();
      return u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.avi');
    }

    Widget mediaWidget;

    if (isVideo(url)) {
      mediaWidget = SizedBox.expand(child: VideoThumbnailOnly(videoUrl: url));
    } else {
      mediaWidget = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorWidget:
            (_, __, ___) => Container(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: const Icon(Icons.broken_image),
            ),
      );
    }

    // Lớp phủ tối màu hiển thị số lượng hình bị ẩn
    if (remainingCount > 0) {
      return Stack(
        fit: StackFit.expand,
        children: [
          mediaWidget,
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return mediaWidget;
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
