import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hld_flutter/presentation/theme/app_colors.dart';
import 'package:hld_flutter/presentation/views/user/home/widgets/ai_search_bar.dart';
import 'package:hld_flutter/presentation/views/user/home/widgets/back_to_top_button.dart';
import 'package:hld_flutter/presentation/views/user/home/widgets/doctor_list.dart';
import 'package:hld_flutter/presentation/views/user/home/widgets/news_ticker.dart';
import 'package:hld_flutter/presentation/views/user/home/widgets/post_card.dart';
import 'package:hld_flutter/presentation/views/user/home/widgets/post_status.dart';
import 'package:hld_flutter/presentation/views/user/home/widgets/section_header.dart';
import 'package:hld_flutter/presentation/views/user/home/widgets/service_grid.dart';
import 'package:hld_flutter/presentation/views/user/home/widgets/specialty_list.dart';
import 'package:hld_flutter/presentation/views/user/home/widgets/welcome_banner.dart';
import 'package:hld_flutter/presentation/viewmodels/post_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/requestmodel/report.dart';
import '../../../../data/models/responsemodel/post.dart';
import '../../../../routes/app_routes.dart';
import '../../../viewmodels/doctor_viewmodel.dart';
import '../../../viewmodels/report_viewmodel.dart';
import '../../../viewmodels/specialty_viewmodel.dart';
import '../../../viewmodels/user_viewmodel.dart';
import '../../skeleton/post_skeleton.dart';
import '../../skeleton/skeleton_box.dart';
import '../../widgets/app_dialog.dart';

const _mockNews = [
  {'id': '1', 'title': 'Cập nhật vaccine Covid-19 mới nhất 2026'},
  {'id': '2', 'title': 'Phòng chống bệnh sốt xuất huyết mùa mưa'},
  {'id': '3', 'title': 'Chế độ dinh dưỡng cho người cao tuổi'},
  {'id': '4', 'title': 'Tầm quan trọng của giấc ngủ với sức khỏe'},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  bool _showBackToTop = false;
  bool _isLoadingNews = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserViewModel>().loadCurrentUser();
      context.read<PostViewModel>().fetchPosts();
      context.read<SpecialtyViewModel>().fetchSpecialties();
      context.read<DoctorViewModel>().fetchDoctors();
    });

    // Simulate loading - xoá khi kết nối API
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoadingNews = false;
        });
      }
    });
  }

  void _onScroll() {
    if (!mounted) return;
    // Hiển thị nút cuộn lên đầu
    final show = _scrollController.offset > 400;
    if (show != _showBackToTop) {
      setState(() => _showBackToTop = show);
    }

    // Load more gọi trực tiếp logic từ ViewModel
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<PostViewModel>().loadMorePosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showReportDialog(BuildContext context, PostResponse post) {
    final TextEditingController reportController = TextEditingController();
    final userVM = context.read<UserViewModel>();
    final reportVM = context.read<ReportViewModel>();
    final currentUser = userVM.currentUser;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Báo cáo bài viết của ${post.userInfo?.name ?? "Bác sĩ"}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Người báo cáo",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  currentUser?.name ?? "Người dùng",
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Loại báo cáo",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const Text("Bài viết", style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 12),
                const Text(
                  "Nội dung báo cáo",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reportController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Nhập nội dung...",
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Huỷ", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightTheme,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Trong hàm onPressed của nút Gửi báo cáo:
              onPressed: () async {
                final content = reportController.text.trim();
                if (content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng nhập nội dung báo cáo"),
                    ),
                  );
                  return;
                }
                final messenger = ScaffoldMessenger.of(context);
                final reportVM = context.read<ReportViewModel>();

                final request = ReportRequest(
                  reporter: currentUser?.id ?? "",
                  reporterModel: currentUser?.role ?? "User",
                  content: content,
                  type: "Bài viết",
                  reportedId: post.userInfo?.id ?? "",
                  postId: post.id,
                );

                final success = await reportVM.sendReport(request);
                if (!mounted) return;

                Navigator.pop(dialogContext);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? "Cảm ơn bạn! Báo cáo đã được gửi."
                          : "Gửi báo cáo thất bại: ${reportVM.error}",
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior:
                        SnackBarBehavior.floating, // Cho nó nổi lên để dễ thấy
                  ),
                );
              },
              child: const Text("Gửi báo cáo"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        color: Colors.white,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                //  HEADER
                SliverToBoxAdapter(child: _buildHeader(context)),
                //  SERVICES
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Dịch vụ toàn diện'),
                      ServiceGrid(
                        onTap: (route) => Navigator.pushNamed(context, route),
                      ),
                    ],
                  ),
                ),

                Consumer<SpecialtyViewModel>(
                  builder: (context, viewModel, child) {
                    return SliverToBoxAdapter(
                      child:
                          viewModel.isLoading
                              ? const _SpecialtySkeletonList()
                              : SpecialtyList(
                                specialties: viewModel.specialties,
                                onTap:
                                    (specialty) => Navigator.pushNamed(
                                      context,
                                      AppRoutes.doctorlistscreen,
                                      arguments: {
                                        'specialtyId': specialty['id'],
                                        'specialtyName': specialty['name'],
                                        'specialtyDesc':
                                            specialty['description'],
                                      },
                                    ),
                              ),
                    );
                  },
                ),

                //  DOCTORS
                Consumer2<DoctorViewModel, UserViewModel>(
                  builder: (context, doctorVM, userVM, child) {
                    final currentUserId = userVM.currentUser?.id ?? '';
                    return SliverToBoxAdapter(
                      child:
                          doctorVM.isLoading
                              ? const _DoctorSkeletonList()
                              : DoctorList(
                                doctors: doctorVM.doctors,
                                onTap: (doctor) {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.otheruserprofile,
                                    arguments: {
                                      'doctorId': doctor.id,
                                      'currentUserId': currentUserId,
                                    },
                                  );
                                },
                              ),
                    );
                  },
                ),
                //  POSTS
                Consumer2<PostViewModel, UserViewModel>(
                  builder: (context, vm, userVM, child) {
                    if (vm.isLoading && vm.posts.isEmpty) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const PostSkeleton(),
                          childCount: 3,
                        ),
                      );
                    }
                    // Lỗi
                    if (vm.isError && vm.posts.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text("Lỗi: ${vm.error}"),
                          ),
                        ),
                      );
                    }

                    // Render danh sách post
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, i) {
                        final post = vm.posts[i];
                        return PostCard(
                          post: post,
                          currentUserId: userVM.currentUser!.id ?? "",
                          onReport: () {
                            _showReportDialog(context, post);
                          },
                          onDelete: () {
                            AppDialog.show(
                              context: context,
                              title: 'Xoá bài viết',
                              content:
                                  'Bạn có chắc muốn xoá bài viết này không?',
                              cancelText: 'Huỷ',
                              cancelBgColor: Colors.grey[200],
                              cancelColor: Colors.black,
                              confirmText: 'Xoá',
                              confirmBgColor: Colors.red,
                              confirmColor: Colors.white,
                              onConfirm: () {
                                final postId = post.id;
                                if (postId != null && postId.isNotEmpty) {
                                  context.read<PostViewModel>().deletePost(
                                    postId,
                                  );
                                }
                              },
                            );
                          },
                          onEdit: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.createpost,
                              arguments: {
                                'postId': post.id,
                                'userId': userVM.currentUser?.id,
                                'userRole': userVM.currentUser?.role,
                              },
                            );
                          },

                          onNavigateToDetail: () {
                            Navigator.pushNamed(
                              context,
                              '/postdetail/${post.id}',
                            );
                          },
                        );
                      }, childCount: vm.posts.length),
                    );
                  },
                ),

                // LOAD MORE INDICATOR
                Consumer<PostViewModel>(
                  builder: (context, postViewModel, child) {
                    if (postViewModel.isLoadingMore) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    } else if (!postViewModel.hasMore &&
                        postViewModel.posts.isNotEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: Text("Đã hết bài viết")),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            ),

            //LAYER 2: Back to top
            if (_showBackToTop)
              Positioned(
                bottom: 90,
                right: 16,
                child: BackToTopButton(
                  onTap:
                      () => _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      ),
                ),
              ),

            Consumer<PostViewModel>(
              builder: (context, postVM, child) {
                final isCreating = postVM.isCreating;
                final isSuccess = postVM.isCreateSuccess;
                final progress = postVM.uploadProgress;

                if (isCreating || isSuccess) {
                  return PostStatusToast(
                    isCreating: isCreating,
                    isSuccess: isSuccess,
                    progress: progress,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.lightTheme.withOpacity(0.1), Colors.white],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 96, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WelcomeBanner(),
          const SizedBox(height: 10),
          _buildGreetingRow(context),
          const SizedBox(height: 16),
          AiSearchBar(
            onSubmit:
                (query) => Navigator.pushNamed(
                  context,
                  '/gemini-help',
                  arguments: {'first_question': query},
                ),
          ),
          const SizedBox(height: 16),
          _isLoadingNews
              ? const _NewsSkeletonList()
              : NewsTicker(
                newsList: List<Map<String, dynamic>>.from(_mockNews),
                onNewsTap:
                    (news) => Navigator.pushNamed(
                      context,
                      '/news-detail',
                      arguments: news,
                    ),
              ),
        ],
      ),
    );
  }

  Widget _buildGreetingRow(BuildContext context) {
    final vm = context.watch<UserViewModel>();
    final user = vm.currentUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào mừng quay lại, 👋',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),

              Text(
                user?.name ?? 'Người dùng',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ],
          ),

          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(blurRadius: 8, color: Colors.black26),
              ],
            ),
            child: ClipOval(
              child:
                  user?.avatarURL != null && user!.avatarURL!.isNotEmpty
                      ? Image.network(user.avatarURL!, fit: BoxFit.cover)
                      : Image.asset(
                        'assets/images/avatar_doctor.jpg',
                        fit: BoxFit.cover,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

// Skeleton
class _SpecialtySkeletonList extends StatelessWidget {
  const _SpecialtySkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Skeleton(width: 100, height: 20),
              Skeleton(width: 60, height: 16),
            ],
          ),
        ),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder:
                (context, _) => Container(
                  width: 110,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Skeleton(width: 80, height: 80, radius: 8),
                      const SizedBox(height: 10),
                      Skeleton(width: double.infinity, height: 14, radius: 4),
                    ],
                  ),
                ),
          ),
        ),
      ],
    );
  }
}

// Skeleton
class _DoctorSkeletonList extends StatelessWidget {
  const _DoctorSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton(width: 120, height: 20),
                Skeleton(width: 60, height: 16),
              ],
            ),
          ),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder:
                  (context, _) => SizedBox(
                    width: 120,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(child: Skeleton(width: 90, height: 90)),
                        const SizedBox(height: 6),
                        Skeleton(width: double.infinity, height: 14, radius: 4),
                        const SizedBox(height: 4),
                        Skeleton(width: double.infinity, height: 12, radius: 4),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// NEWS SKELETON
class _NewsSkeletonList extends StatelessWidget {
  const _NewsSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Skeleton(
                      width: double.infinity,
                      height: 16,
                      radius: 4,
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 5),
              Divider(
                color: Theme.of(context).colorScheme.secondaryContainer,
                thickness: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
