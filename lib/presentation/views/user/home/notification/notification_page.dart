import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/responsemodel/notification.dart';
import '../../../../theme/app_colors.dart';
import '../../../../viewmodels/notification_viewmodel.dart';
import '../../../../viewmodels/user_viewmodel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _showOnlyUnread = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final userVM = context.read<UserViewModel>();
    final notifVM = context.read<NotificationViewModel>();
    final userId = userVM.currentUser?.id ?? '';

    if (userId.isNotEmpty) {
      if (_showOnlyUnread) {
        notifVM.fetchUnreadNotifications(userId);
      } else {
        notifVM.fetchNotificationByUserId(userId);
      }
    }
  }

  // Chuyển đổi trạng thái filter
  void _toggleFilter(bool showUnread) {
    setState(() => _showOnlyUnread = showUnread);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final notifVM = context.watch<NotificationViewModel>();
    final notifications = notifVM.notifications;
    final isLoading = notifVM.isLoading;
    final unreadCount = notifVM.unreadCount;
    final userVM = context.read<UserViewModel>();
    final userId = userVM.currentUser?.id ?? '';
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // TOP BAR & THỐNG KÊ
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.lightTheme,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Thông báo",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 10),
                            _UnreadBadge(count: unreadCount),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              FilterChip(
                                selected: !_showOnlyUnread,
                                onSelected: (_) => _toggleFilter(false),
                                label: const Text("Tất cả"),
                                showCheckmark: true,
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                selected: _showOnlyUnread,
                                onSelected: (_) => _toggleFilter(true),
                                label: const Text("Chưa đọc"),
                                showCheckmark: true,
                              ),
                            ],
                          ),
                          if (unreadCount > 0)
                            TextButton.icon(
                              onPressed: () => notifVM.markAllAsRead(userId),
                              icon: const Icon(
                                Icons.done_all,
                                size: 18,
                                color: Colors.black,
                              ),
                              label: const Text(
                                "Đọc hết",
                                style: TextStyle(fontSize: 13),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // DANH SÁCH THÔNG BÁO
            Expanded(
              child: Stack(
                children: [
                  if (notifications.isEmpty && !isLoading)
                    const _EnhancedEmptyState()
                  else
                    RefreshIndicator(
                      onRefresh: () async => _loadData(),
                      child: _NotificationList(
                        notifications: notifications,
                        notifVM: notifVM,
                      ),
                    ),

                  if (isLoading)
                    LinearProgressIndicator(
                      color: cs.primary,
                      backgroundColor: Colors.transparent,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  HUY HIỆU ĐẾM SỐ THÔNG BÁO
class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? "99+" : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── COMPONENT: EMPTY STATE
class _EnhancedEmptyState extends StatefulWidget {
  const _EnhancedEmptyState();

  @override
  State<_EnhancedEmptyState> createState() => _EnhancedEmptyStateState();
}

class _EnhancedEmptyStateState extends State<_EnhancedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnim,
              child: Icon(
                Icons.notifications_outlined,
                size: 100,
                color: cs.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Chưa có thông báo",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: cs.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Các thông báo mới sẽ xuất hiện ở đây",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSecondaryContainer.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// XỬ LÝ LIST VIEW VÀ HEADER
class _NotificationList extends StatelessWidget {
  final List<NotificationResponse> notifications;
  final NotificationViewModel notifVM;

  const _NotificationList({required this.notifications, required this.notifVM});

  @override
  Widget build(BuildContext context) {
    //  Sort giảm dần theo thời gian
    final sortedList = List.from(notifications)..sort((a, b) {
      final timeA = DateTime.parse(a.createdAt).toUtc();
      final timeB = DateTime.parse(b.createdAt).toUtc();
      return timeB.compareTo(timeA);
    });

    // Chia mảng Hôm nay và Trước đó
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final today = DateTime(now.year, now.month, now.day);

    final todayList = [];
    final pastList = [];

    for (var n in sortedList) {
      final d = DateTime.parse(
        n.createdAt,
      ).toUtc().add(const Duration(hours: 7));
      final dateOnly = DateTime(d.year, d.month, d.day);
      if (dateOnly.isAtSameMomentAs(today)) {
        todayList.add(n);
      } else {
        pastList.add(n);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        if (todayList.isNotEmpty) ...[
          const _SectionHeader(title: "Hôm nay"),
          ...todayList
              .map((n) => _NotificationCard(notification: n, notifVM: notifVM))
              .toList(),
        ],
        if (pastList.isNotEmpty) ...[
          const SizedBox(height: 8),
          const _SectionHeader(title: "Trước đó"),
          ...pastList
              .map((n) => _NotificationCard(notification: n, notifVM: notifVM))
              .toList(),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
        ),
      ),
    );
  }
}

//  CARD THÔNG BÁO VÀ CÁC ACTION CLICK
class _NotificationCard extends StatelessWidget {
  final NotificationResponse notification;
  final NotificationViewModel notifVM;

  const _NotificationCard({required this.notification, required this.notifVM});

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Xóa thông báo"),
            content: const Text("Bạn có chắc chắn muốn xóa thông báo này?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Hủy", style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () {
                  notifVM.deleteNotification(notification.id);
                  Navigator.pop(ctx);
                },
                child: Text("Xóa", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => SafeArea(
            child: InkWell(
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteDialog(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Xóa thông báo",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUnread = !notification.isRead;
    final cardBg =
        isUnread ? AppColors.lightTheme.withOpacity(0.3) : Colors.white;
    final borderColor =
        isUnread ? Colors.black.withOpacity(0.25) : Colors.white;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (isUnread) notifVM.markAsRead(notification.id);

          if (notification.navigatePath == 'appointment') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false,
              arguments: {
                'tabIndex': 1,
              },
            );
          } else if (notification.navigatePath.isNotEmpty) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              notification.navigatePath,
              (route) => false,
            );
          }
        },
        onLongPress: () => _showBottomSheet(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // Icon
              _NotificationIcon(
                isRead: !isUnread,
                content: notification.content,
              ),
              const SizedBox(width: 12),

              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            isUnread ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: cs.onSurface.withOpacity(0.45),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeAgoInVietnam(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.45),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Mới",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron Right
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: cs.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final bool isRead;
  final String content;

  const _NotificationIcon({required this.isRead, required this.content});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lowerContent = content.toLowerCase();

    IconData iconData = Icons.notifications_outlined;
    if (lowerContent.contains('lịch hẹn') ||
        lowerContent.contains('appointment')) {
      iconData = Icons.calendar_today_outlined;
    } else if (lowerContent.contains('thuốc') ||
        lowerContent.contains('medication')) {
      iconData = Icons.medical_services_outlined;
    } else if (lowerContent.contains('thanh toán') ||
        lowerContent.contains('payment')) {
      iconData = Icons.payment_outlined;
    } else if (lowerContent.contains('bác sĩ') ||
        lowerContent.contains('doctor')) {
      iconData = Icons.person_outline;
    } else if (lowerContent.contains('kết quả') ||
        lowerContent.contains('result')) {
      iconData = Icons.assignment_outlined;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isRead ? Colors.grey.shade300 : AppColors.lightTheme,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        iconData,
        size: 22,
        color: isRead ? cs.onSurfaceVariant : cs.primary,
      ),
    );
  }
}

// FORMAT THỜI GIAN THEO MÚI GIỜ VIỆT NAM
String timeAgoInVietnam(String createdAt) {
  try {
    final DateTime utcTime = DateTime.parse(createdAt).toUtc();
    final DateTime vietnamTime = utcTime.add(const Duration(hours: 7));
    final DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));

    final Duration difference = now.difference(vietnamTime);
    if (difference.inMinutes < 1) return "Vừa xong";
    if (difference.inMinutes < 60) return "${difference.inMinutes} phút trước";
    if (difference.inHours < 24) return "${difference.inHours} giờ trước";
    if (difference.inDays == 1) return "Hôm qua";
    if (difference.inDays < 7) return "${difference.inDays} ngày trước";

    return "${vietnamTime.day.toString().padLeft(2, '0')}/${vietnamTime.month.toString().padLeft(2, '0')}/${vietnamTime.year}";
  } catch (e) {
    return "Không xác định";
  }
}
