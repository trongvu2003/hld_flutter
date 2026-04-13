import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hld_flutter/routes/app_routes.dart';
import 'package:hld_flutter/viewmodels/user_viewmodel.dart';
import 'package:hld_flutter/views/user/home/widgets/video_thumbnail_only.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/responsemodel/post.dart';
import '../../../../theme/app_colors.dart';
import '../../../skeleton/skeleton_box.dart';
import '../../post/comment_bottom_sheet.dart';
import '../../post/media_detail_screen.dart';

class PostCard extends StatelessWidget {
  final PostResponse post;
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
    final userInfo = post.userInfo;
    final images = post.media;
    final isOwner = currentUserId == userInfo?.id;
    final avatar = userInfo?.avatarUrl;
    final userVM = context.watch<UserViewModel>().currentUser;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white,
      child: Card(
        color: Colors.white,
        elevation: 2,
        borderOnForeground: true,
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
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (post.userInfo?.id == userVM?.id) {
                          Navigator.pushNamed(context, AppRoutes.personal);
                        } else {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.otheruserprofile,
                            arguments: {'userOwnerID': userInfo?.id},
                          );
                          print("User dc bam ${userInfo?.id}");
                        }
                      },
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
                                        placeholder:
                                            (context, url) => const Skeleton(
                                              width: 45,
                                              height: 45,
                                              radius: 22.5,
                                            ),
                                        errorWidget:
                                            (
                                              context,
                                              url,
                                              error,
                                            ) => Image.asset(
                                              'assets/images/avatar_doctor.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                      )
                                      : Image.asset(
                                        'assets/images/avatar_doctor.jpg',
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userInfo?.name ?? 'Người dùng',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatTime(post.createdAt),
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
            if ((post.content ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Text(post.content),
              ),

            // Media Grid (Hỗ trợ nhiều Ảnh và Video)
            if (images.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: _buildMediaGrid(images, context),
                  ),
                ),
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
                        // Text('${post. ?? 0}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder:
                                  (_) => CommentBottomSheet(
                                    postId: post.id ?? "",
                                    currentUserId: userVM!.id ?? "",
                                  ),
                            );
                          },
                          icon: const Icon(Icons.comment_outlined),
                          iconSize: 30,
                        ),
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

  Widget _buildMediaGrid(List images, BuildContext context) {
    int count = images.length;

    if (count == 1) {
      return SizedBox(
        height: 250,
        child: _buildMediaItem(images[0].toString(), context, 0, images),
      );
    }

    if (count == 2) {
      return SizedBox(
        height: 250,
        child: Row(
          children: [
            Expanded(
              child: _buildMediaItem(images[0].toString(), context, 0, images),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: _buildMediaItem(images[1].toString(), context, 1, images),
            ),
          ],
        ),
      );
    }

    if (count == 3) {
      return SizedBox(
        height: 250,
        child: Row(
          children: [
            Expanded(
              child: _buildMediaItem(images[0].toString(), context, 0, images),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _buildMediaItem(
                      images[1].toString(),
                      context,
                      1,
                      images,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: _buildMediaItem(
                      images[2].toString(),
                      context,
                      2,
                      images,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildMediaItem(
                    images[0].toString(),
                    context,
                    0,
                    images,
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _buildMediaItem(
                    images[1].toString(),
                    context,
                    1,
                    images,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildMediaItem(
                    images[2].toString(),
                    context,
                    2,
                    images,
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _buildMediaItem(
                    images[3].toString(),
                    context,
                    3,
                    images,
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

  Widget _buildMediaItem(
    String url,
    BuildContext context,
    int currentIndex,
    List allMedia, {
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
        placeholder:
            (context, url) => const Skeleton(
              width: double.infinity,
              height: double.infinity,
              radius: 0,
            ),
        errorWidget:
            (_, __, ___) => Container(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: const Icon(Icons.broken_image),
            ),
      );
    }

    Widget finalWidget = mediaWidget;

    if (remainingCount > 0) {
      finalWidget = Stack(
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
    return GestureDetector(
      onTap: () {
        List<String> stringMediaList =
            allMedia.map((e) => e.toString()).toList();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => MediaDetailScreen(
                  mediaUrls: stringMediaList,
                  initialIndex: currentIndex,
                ),
          ),
        );
      },
      child: finalWidget,
    );
  }
}

String formatTime(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';

  final parsedDate = DateTime.tryParse(dateStr);
  if (parsedDate == null) return '';

  return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
}
