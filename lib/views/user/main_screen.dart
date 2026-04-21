import 'package:flutter/material.dart';
import 'package:hld_flutter/views/user/home/home_screen.dart';
import 'package:hld_flutter/views/user/home/personal/use_owner_profile.dart';
import 'package:provider/provider.dart';
import '../../services/NotificationServiceFirebase.dart';
import '../../viewmodels/user_viewmodel.dart';
import 'booking/appointment_list_screen.dart';
import 'fooder_bar.dart';
import 'header_bar.dart';
import 'home/notification/notification_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _barsVisible = true;
  bool _isInit = false;

  //  Mảng đánh dấu các tab đã được truy cập (Khởi tạo toàn false)
  final List<bool> _visitedTabs = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final userVM = context.read<UserViewModel>();
      await userVM.loadCurrentUser();
      await _uploadFcmToken();
    });
  }

  Future<void> _uploadFcmToken() async {
    final userVM = context.read<UserViewModel>();

    final user = userVM.currentUser;

    if (user == null) {
      debugPrint("User chưa sẵn sàng");
      return;
    }

    final token = await NotificationServiceFirebase().getToken();

    if (token == null || token.isEmpty) {
      debugPrint("FCM token null");
      return;
    }

    try {
      await userVM.sendFcmToken(user.id ?? '', user.role ?? '', token);

      debugPrint("Đã gửi FCM token");
    } catch (e) {
      debugPrint("Lỗi gửi FCM: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;
      if (rawArgs is Map) {
        _currentIndex = rawArgs['tabIndex'] ?? 0;
      }
      // Đánh dấu tab khởi đầu là đã truy cập
      _visitedTabs[_currentIndex] = true;
      _isInit = true;
    }
  }

  bool _onScroll(ScrollNotification n) {
    if (n is ScrollUpdateNotification) {
      final delta = n.scrollDelta ?? 0;
      final show = delta < 0;
      if (show != _barsVisible) setState(() => _barsVisible = show);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isHome = _currentIndex == 0;
    final userViewModel = context.watch<UserViewModel>();
    final user = userViewModel.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Chỉ build màn hình thật nếu nó đã được truy cập (_visitedTabs == true)
    // Nếu chưa truy cập, trả về SizedBox.shrink() (widget rỗng, không tốn tài nguyên)
    final List<Widget> screens = [
      _visitedTabs[0] ? const HomeScreen() : const SizedBox.shrink(),
      _visitedTabs[1]
          ? AppointmentListScreen(
            userRole: user.role ?? 'User',
            userId: user.id ?? '',
          )
          : const SizedBox.shrink(),

      _visitedTabs[2] ? const NotificationScreen() : const SizedBox.shrink(),
      _visitedTabs[3] ? const ProfileUserPage() : const SizedBox.shrink(),
    ];

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Stack(
          children: [
            // ── 1. Nội dung tab
            IndexedStack(index: _currentIndex, children: screens),

            // ── 2. HeadBar - chỉ hiện tab home
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: (isHome && _barsVisible) ? 0 : -100,
              left: 0,
              right: 0,
              child: HeadBar(userName: user.name),
            ),

            // ── 3. FootBar - luôn hiện, ẩn khi scroll xuống
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              bottom: _barsVisible ? 0 : -100,
              left: 0,
              right: 0,
              child: FootBar(
                currentIndex: _currentIndex,
                onTap: (i) {
                  setState(() {
                    _currentIndex = i;
                    // Đánh dấu tab này đã được truy cập để build giao diện
                    _visitedTabs[i] = true;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
