import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../theme/app_colors.dart';
import '../../../../viewmodels/user_viewmodel.dart';

class EditUserProfile extends StatefulWidget {
  const EditUserProfile({Key? key}) : super(key: key);

  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repasswordController = TextEditingController();

  File? _avatarFile;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().loadCurrentUser();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _repasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final user = userViewModel.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isInitialized) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _addressController.text = user.address;
      _isInitialized = true;
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
          "Chỉnh sửa hồ sơ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _ChangeAvatar(
              avatarUrl: user.avatarURL ?? '',
              imageFile: _avatarFile,
              onImageSelected: (file) {
                setState(() {
                  _avatarFile = file;
                });
              },
            ),
            const SizedBox(height: 20),
            _ContentEditUser(
              nameController: _nameController,
              emailController: _emailController,
              phoneController: _phoneController,
              addressController: _addressController,
              passwordController: _passwordController,
              repasswordController: _repasswordController,
            ),
            const SizedBox(height: 20),
            _AcceptEditButton(
              userId: user.id,
              role: user.role,
              nameController: _nameController,
              emailController: _emailController,
              phoneController: _phoneController,
              addressController: _addressController,
              passwordController: _passwordController,
              repasswordController: _repasswordController,
              avatarFile: _avatarFile,
              viewModel: userViewModel,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ChangeAvatar extends StatelessWidget {
  final String avatarUrl;
  final File? imageFile;
  final Function(File) onImageSelected;

  const _ChangeAvatar({
    required this.avatarUrl,
    required this.imageFile,
    required this.onImageSelected,
  });

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onImageSelected(File(image.path));
      }
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text("Cần quyền truy cập"),
              content: const Text(
                "Ứng dụng cần quyền truy cập ảnh để thay đổi avatar.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Đóng"),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: GestureDetector(
          onTap: () => _pickImage(context),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightTheme, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image:
                          imageFile != null
                              ? FileImage(imageFile!) as ImageProvider
                              : CachedNetworkImageProvider(avatarUrl),
                    ),
                  ),
                ),
                // Icon Camera đè lên ảnh
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: theme.colorScheme.background,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentEditUser extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController passwordController;
  final TextEditingController repasswordController;

  const _ContentEditUser({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.passwordController,
    required this.repasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        children: [
          _InputEditField(label: "Họ và tên", controller: nameController),
          const SizedBox(height: 12),
          _InputEditField(label: "Email", controller: emailController),
          const SizedBox(height: 12),
          _InputEditField(label: "Số điện thoại", controller: phoneController),
          const SizedBox(height: 12),
          _InputEditField(
            label: "Địa chỉ",
            controller: addressController,
            maxLines: null,
          ),
          const SizedBox(height: 12),
          _InputEditField(
            label: "Mật khẩu",
            controller: passwordController,
            isPassword: true,
          ),
          const SizedBox(height: 12),
          _InputEditField(
            label: "Nhập lại mật khẩu",
            controller: repasswordController,
            isPassword: true,
          ),
        ],
      ),
    );
  }
}

class _InputEditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final int? maxLines;

  const _InputEditField({
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          maxLines: isPassword ? 1 : maxLines,
          keyboardType:
              (maxLines == null || (maxLines ?? 0) > 1)
                  ? TextInputType.multiline
                  : TextInputType.text,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _AcceptEditButton extends StatelessWidget {
  final String userId;
  final String role;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController passwordController;
  final TextEditingController repasswordController;
  final File? avatarFile;
  final UserViewModel viewModel;

  const _AcceptEditButton({
    required this.userId,
    required this.role,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.passwordController,
    required this.repasswordController,
    required this.avatarFile,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // Chú ý: trong UserViewModel của bạn biến này tên là `isLoading`
        onPressed:
            viewModel.isLoading
                ? null
                : () async {
                  // Kiểm tra mật khẩu (chỉ check khi người dùng có nhập mật khẩu mới)
                  if (passwordController.text.isNotEmpty &&
                      passwordController.text != repasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mật khẩu không khớp")),
                    );
                    return;
                  }

                  // Gọi hàm updateUser trong ViewModel
                  await viewModel.updateUser(
                    avatarFile: avatarFile,
                    name:
                        nameController.text.isNotEmpty
                            ? nameController.text
                            : null,
                    email:
                        emailController.text.isNotEmpty
                            ? emailController.text
                            : null,
                    address:
                        addressController.text.isNotEmpty
                            ? addressController.text
                            : null,
                    phone:
                        phoneController.text.isNotEmpty
                            ? phoneController.text
                            : null,
                    // Chỉ gửi password nếu người dùng có nhập
                    password:
                        passwordController.text.isNotEmpty
                            ? passwordController.text
                            : null,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cập nhật thành công")),
                    );
                    Navigator.pop(context);
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightTheme,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            viewModel.isLoading
                ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 15),
                    Text(
                      "Đang lưu...",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                : const Text(
                  "Lưu thay đổi",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}
