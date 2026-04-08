import 'package:flutter/material.dart';
import 'package:hld_flutter/views/user/home/home_screen.dart';
import 'package:provider/provider.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserViewModel>().loadUser();
    });
  }

  //  Để hứng arguments truyền từ Navigator sang
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final rawArgs = ModalRoute.of(context)?.settings.arguments;
      if (rawArgs is Map) {
        _currentIndex = rawArgs['tabIndex'] ?? 0;
      }
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
    final userViewModel= context.watch<UserViewModel>();
    final user= userViewModel.user;
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> screens = [
      const HomeScreen(),
      AppointmentListScreen(
        userRole: user?.role ?? 'User',
        userId: user?.id ?? '',
      ),
      const NotificationScreen(),
      const _PlaceholderScreen(label: 'Cá nhân'),
    ];

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Stack(
          children: [

            // ── 1. Nội dung tab
            IndexedStack(
              index: _currentIndex,
              children: screens,
            ),

            // ── 2. HeadBar - chỉ hiện tab home
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: (isHome && _barsVisible) ? 0 : -100,
              left: 0,
              right: 0,
              child: HeadBar(userName: user?.name),
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
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// Placeholder tạm - xoá khi làm màn thật
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}