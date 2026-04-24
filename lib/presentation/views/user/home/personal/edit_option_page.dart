import 'package:flutter/material.dart';
import 'package:hld_flutter/routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../viewmodels/user_viewmodel.dart';

class EditOptionPage extends StatefulWidget {
  const EditOptionPage({Key? key}) : super(key: key);

  @override
  State<EditOptionPage> createState() => _EditOptionPageState();
}

class _EditOptionPageState extends State<EditOptionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().loadCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserViewModel>().currentUser;
    final clinicButtonText =
        (user?.role == "User") ? "Đăng kí phòng khám" : "Quản lý phòng khám";
    print("role là: ${user?.role}");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.lightTheme,
        elevation: 8,
        shadowColor: Colors.black45,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Chỉnh sửa",
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
            // Edit Profile
            EditOptionItem(
              text: "Chỉnh sửa thông tin cá nhân",
              icon: Icons.person,
              onClick: () {
                Navigator.pushNamed(context, '/editprofile');
              },
            ),

            const SizedBox(height: 16),
            // Clinic Management
            EditOptionItem(
              text: clinicButtonText,
              icon: Icons.medical_services,
              onClick: () {
                if (user == null) return;
                if (user.role == "User") {
                  Navigator.pushNamed(context, AppRoutes.doctorRegister);
                } else {
                  Navigator.pushNamed(context, AppRoutes.editClinic);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}


class EditOptionItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onClick;

  const EditOptionItem({
    Key? key,
    required this.text,
    required this.icon,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.onSecondaryContainer,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: theme.colorScheme.onSecondaryContainer,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
