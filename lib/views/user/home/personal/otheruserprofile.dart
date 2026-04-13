import 'package:flutter/material.dart';
import 'package:hld_flutter/views/user/home/personal/widgets/otherprofile.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/post_viewmodel.dart';
import '../../../../viewmodels/user_viewmodel.dart';
import '../../../widgets/avatar_detail_dialog.dart';
import '../doctor/widgets/other_posts_tab.dart';

class ProfileOtherUserPage extends StatefulWidget {
  final String userOwnerID;

  const ProfileOtherUserPage({Key? key, required this.userOwnerID})
    : super(key: key);

  @override
  State<ProfileOtherUserPage> createState() => _ProfileOtherUserPageState();
}

class _ProfileOtherUserPageState extends State<ProfileOtherUserPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showMediaDetail = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserViewModel>().loadOtherUser(widget.userOwnerID);
      print("User nhận đc ${widget.userOwnerID}");
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final postVM = context.read<PostViewModel>();

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (postVM.hasMore && !postVM.hasMore) {
        postVM.loadMorePosts();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _showReportUserDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text("Báo cáo người dùng"),
        content: const Text("Nội dung báo cáo..."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final userOfThisProfile = userVM.userOfThisProfile;
    final isLoadingInit = userVM.isLoading;

    if (isLoadingInit || userOfThisProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: OtherUserIntroSection(
                user: userOfThisProfile,
                onImageClick: (url) => _showAvatarDialog(context, url),
                onToggleReportBox: () => _showReportUserDialog(),
              ),
            ),
          ];
        },
        body: PostsTab(
          userID: userOfThisProfile.id,
          currentUserId: userOfThisProfile.id,
        ),
      ),
    );
  }
}
