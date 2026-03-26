import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hld_flutter/theme/app_colors.dart';
import 'package:hld_flutter/viewmodels/post_viewmodel.dart';
import 'package:hld_flutter/views/user/home/widgets/ai_search_bar.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/specialty_viewmodel.dart';
import '../../../viewmodels/user_viewmodel.dart';
import '../../skeleton/skeleton_box.dart';
import '../../widgets/app_dialog.dart';
import 'widgets/back_to_top_button.dart';
import 'widgets/doctor_list.dart';
import 'widgets/news_ticker.dart';
import 'widgets/post_card.dart';
import 'widgets/section_header.dart';
import 'widgets/service_grid.dart';
import 'widgets/specialty_list.dart';
import 'widgets/welcome_banner.dart';

const _mockNews = [
  {'id': '1', 'title': 'Cập nhật vaccine Covid-19 mới nhất 2026'},
  {'id': '2', 'title': 'Phòng chống bệnh sốt xuất huyết mùa mưa'},
  {'id': '3', 'title': 'Chế độ dinh dưỡng cho người cao tuổi'},
  {'id': '4', 'title': 'Tầm quan trọng của giấc ngủ với sức khỏe'},
];

const _mockDoctors = [
  {
    'id': '1',
    'name': 'BS. Trần Văn B',
    'avatarURL': 'assets/images/avatar_doctor.jpg',
    'specialty': {'name': 'Tim mạch'},
  },
  {
    'id': '2',
    'name': 'BS. Lê Thị C',
    'avatarURL': 'assets/images/avatar_doctor.jpg',
    'specialty': {'name': 'Nhi khoa'},
  },
  {
    'id': '3',
    'name': 'BS. Phạm Văn D',
    'avatarURL': 'assets/images/avatar_doctor.jpg',
    'specialty': {'name': 'Da liễu'},
  },
  {
    'id': '4',
    'name': 'BS. Hoàng Thị E',
    'avatarURL': 'assets/images/avatar_doctor.jpg',
    'specialty': {'name': 'Thần kinh'},
  },
  {
    'id': '5',
    'name': 'BS. Nguyễn Văn F',
    'avatarURL': 'assets/images/avatar_doctor.jpg',
    'specialty': {'name': 'Mắt'},
  },
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  bool _showBackToTop = false;

  // Mock loading states - thay bằng ViewModel sau
  bool _isLoadingDoctors = true;
  bool _isLoadingNews = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserViewModel>().loadUser();
      context.read<PostViewModel>().fetchPosts();
      context.read<SpecialtyViewModel>().fetchSpecialties();
    });

    // Simulate loading - xoá khi kết nối API
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoadingDoctors = false;
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

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Container(
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
                      child: viewModel.isLoading
                          ? const _SpecialtySkeletonList()
                          : SpecialtyList(
                        specialties: viewModel.specialties,
                        onTap: (specialty) => Navigator.pushNamed(
                          context,
                          '/doctor-list',
                          arguments: specialty,
                        ),
                      ),
                    );
                  },
                ),

                //  DOCTORS
                SliverToBoxAdapter(
                  child:
                      _isLoadingDoctors
                          ? const _DoctorSkeletonList()
                          : DoctorList(
                            doctors: List<Map<String, dynamic>>.from(
                              _mockDoctors,
                            ),
                            onTap:
                                (doctor) => Navigator.pushNamed(
                                  context,
                                  '/doctor-screen',
                                  arguments: doctor,
                                ),
                          ),
                ),
                //  POSTS
                Consumer<PostViewModel>(
                  builder: (context, vm, child) {
                    if (vm.isLoading && vm.posts.isEmpty) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) => const _PostSkeleton(),
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
                          post: {
                            'id': post.id,
                            'content': post.content,
                            'media': post.media,
                            'userInfo':
                                post.userInfo != null
                                    ? {
                                      '_id': post.userInfo!.id,
                                      'name': post.userInfo!.name,
                                      'avatarURL': post.userInfo!.avatarUrl,
                                    }
                                    : null,
                            'createdAt': post.createdAt,
                          },
                          currentUserId: '',
                          // Bạn có thể truyền User ID từ UserViewModel vào đây
                          onReport: () {
                            AppDialog.show(
                              context: context,
                              title: 'Báo cáo bài viết',
                              content: 'Chọn lý do báo cáo',
                              confirmText: 'Gửi',
                              onConfirm: () {},
                            );
                          },
                          onDelete: () {
                            AppDialog.show(
                              context: context,
                              title: 'Xoá bài viết',
                              content: 'Bạn có chắc muốn xoá?',
                              confirmText: 'Xoá',
                              confirmColor: Colors.red,
                              onConfirm: () {},
                            );
                          },
                          onNavigateToDetail: () {
                            Navigator.pushNamed(
                              context,
                              '/post-detail/${post.id}',
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
    final user = vm.user;

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
              color: Theme.of(context).colorScheme.primary,
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
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

// POST SKELETON
class _PostSkeleton extends StatelessWidget {
  const _PostSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar & Info
          Row(
            children: [
              Skeleton(width: 45, height: 45, radius: 25), // Avatar
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 120, height: 16, radius: 4), // Tên
                  const SizedBox(height: 6),
                  Skeleton(width: 80, height: 12, radius: 4), // Thời gian
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Skeleton(width: double.infinity, height: 14, radius: 4),
          const SizedBox(height: 6),
          Skeleton(width: double.infinity, height: 14, radius: 4),
          const SizedBox(height: 6),
          Skeleton(width: 200, height: 14, radius: 4),
          const SizedBox(height: 16),

          // Media Box (Ảnh bài viết)
          Skeleton(width: double.infinity, height: 200, radius: 10),
          const SizedBox(height: 16),

          // Footer Actions (Like, Comment, Share)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Skeleton(width: 40, height: 20, radius: 4),
              Skeleton(width: 40, height: 20, radius: 4),
              Skeleton(width: 40, height: 20, radius: 4),
            ],
          )
        ],
      ),
    );
  }
}