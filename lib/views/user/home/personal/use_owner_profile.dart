import 'package:flutter/material.dart';
import 'package:hld_flutter/views/user/home/personal/widgets/myprofile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../viewmodels/post_viewmodel.dart';
import '../../../../viewmodels/user_viewmodel.dart';
import '../../../widgets/avatar_detail_dialog.dart';
import '../doctor/widgets/other_posts_tab.dart';

class ProfileUserPage extends StatefulWidget {
  const ProfileUserPage({Key? key}) : super(key: key);

  @override
  State<ProfileUserPage> createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showMediaDetail = false;
  String? _selectedImageUrl;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (!mounted) return;
    context.read<UserViewModel>().loadUser();
    if (userId != null) {
      context.read<PostViewModel>().getPostByUserId(
        userId: userId,
        skip: 0,
        limit: 10,
        append: false,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserViewModel>().user;
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {},
          child: ListView.builder(
            controller: _scrollController,
            itemCount: 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ProfileSection(
                  user: user,
                  onImageClick: (url) {
                    setState(() {
                      _selectedImageUrl = url;
                      _showMediaDetail = true;
                      _showAvatarDialog(context, url);
                    });
                  },
                );
              }
              return PostsTab(userID: user.id, currentUserId: user.id);
            },
          ),
        ),
      ),
    );
  }

  void _showAvatarDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (_) => AvatarDetailDialog(mediaUrl: url),
    ).then((_) {
      if (mounted) {
        setState(() => _showMediaDetail = false);
      }
    });
  }
}
