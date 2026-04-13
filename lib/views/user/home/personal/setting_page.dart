import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../theme/app_colors.dart';
import '../../../../viewmodels/user_viewmodel.dart';
class SettingScreen extends StatefulWidget {

  const SettingScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().loadCurrentUser();
    });
  }

  Future<void> _logoutWithGoogle(BuildContext context) async {
    try {
      // 1. Xóa Token trong SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken'); // Hoặc 'access_token' tuỳ bạn đặt
      // 2. Ngắt kết nối Socket
      // widget.socketManager.disconnect();
      // 3. Đăng xuất khỏi Firebase
      // await FirebaseAuth.instance.signOut();
      // // 4. Đăng xuất khỏi Google
      // await GoogleSignIn.instance.signOut();
      // 5. Chuyển hướng về StartScreen và xóa hết lịch sử trang
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đăng xuất thành công!")));
        // Thay '/intro1' bằng route trỏ tới màn hình StartScreen/Đăng nhập của bạn
        Navigator.pushNamedAndRemoveUntil(context, '/intro1', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Lỗi khi đăng xuất ")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: AppColors.lightTheme,
        elevation: 8,
        shadowColor: Colors.black45,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Cài đặt",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dark Mode
            SettingItem(
              text: "Chế độ tối",
              icon: Icons.dark_mode,
              onClick: (){},
            ),
            const SizedBox(height: 16),

            // Activity Manager
            SettingItem(
              text: "Quản lý hoạt động",
              icon: Icons.history,
              onClick: () {
                Navigator.pushNamed(context, '/activity_manager');
              },
            ),
            const SizedBox(height: 16),

            // Report Manager
            SettingItem(
              text: "Quản lý khiếu nại",
              icon: Icons.report,
              onClick: () {
                Navigator.pushNamed(context, '/report_manager');
              },
            ),
            const SizedBox(height: 16),

            // Logout
            SettingItem(
              text: "Đăng xuất",
              icon: Icons.logout,
              isDestructive: true,
              onClick: () => _logoutWithGoogle(context),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onClick;
  final bool isDestructive;

  const SettingItem({
    Key? key,
    required this.text,
    required this.icon,
    required this.onClick,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Xử lý màu sắc dựa trên isDestructive
    final backgroundColor =
        isDestructive
            ? Colors.red.shade100
            : Colors.grey.shade300;

    final contentColor =
        isDestructive
            ? theme.colorScheme.error
            : theme.colorScheme.onSecondaryContainer;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: contentColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: contentColor,
                  ),
                ),
              ),
              if (!isDestructive)
                Icon(Icons.keyboard_arrow_right, color: contentColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
