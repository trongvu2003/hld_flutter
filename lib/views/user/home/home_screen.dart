import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hld_flutter/theme/app_colors.dart';
import 'package:hld_flutter/views/user/home/widgets/ai_search_bar.dart';
import '../../skeleton/skeleton_box.dart';
import 'widgets/back_to_top_button.dart';
import 'widgets/doctor_list.dart';
import 'widgets/news_ticker.dart';
import 'widgets/post_card.dart';
import 'widgets/section_header.dart';
import 'widgets/service_grid.dart';
import 'widgets/specialty_list.dart';
import 'widgets/welcome_banner.dart';

const _mockUser = {
  'name': 'Bùi Trọng Vũ',
  'avatarURL': 'assets/images/avatar_doctor.jpg',
};

const _mockNews = [
  {'id': '1', 'title': 'Cập nhật vaccine Covid-19 mới nhất 2026'},
  {'id': '2', 'title': 'Phòng chống bệnh sốt xuất huyết mùa mưa'},
  {'id': '3', 'title': 'Chế độ dinh dưỡng cho người cao tuổi'},
  {'id': '4', 'title': 'Tầm quan trọng của giấc ngủ với sức khỏe'},
];

const _mockSpecialties = [
  {'id': '1', 'name': 'Tim mạch', 'image': "assets/images/heart.png"},
  {'id': '2', 'name': 'Nhi khoa', 'image': "assets/images/heart.png"},
  {'id': '3', 'name': 'Da liễu', 'image': "assets/images/heart.png"},
  {'id': '4', 'name': 'Thần kinh', 'image': "assets/images/heart.png"},
  {'id': '5', 'name': 'Xương khớp', 'image': "assets/images/heart.png"},
  {'id': '6', 'name': 'Mắt', 'image': "assets/images/heart.png"},
  {'id': '7', 'name': 'Tai mũi họng', 'image': "assets/images/heart.png"},
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

const _mockPosts = [
  {
    'id': '1',
    'userInfo': {'id': 'u1', 'name': 'Trần Thị A', 'avatarURL': ''},
    'content':
        'Hôm nay thời tiết thay đổi, mọi người nhớ giữ ấm và uống nhiều nước nhé!',
    'images': [],
    'likesCount': 12,
    'commentsCount': 3,
    'createdAt': '2 giờ trước',
  },
  {
    'id': '2',
    'userInfo': {'id': 'u2', 'name': 'Lê Văn B', 'avatarURL': ''},
    'content':
        'Chia sẻ bài tập thể dục buổi sáng giúp tăng sức đề kháng hiệu quả.',
    'images': [],
    'likesCount': 24,
    'commentsCount': 8,
    'createdAt': '5 giờ trước',
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
  bool _isLoadingSpecialties = true;
  bool _isLoadingDoctors = true;
  bool _isLoadingNews = true;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;

  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Simulate loading - xoá khi kết nối API
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoadingSpecialties = false;
          _isLoadingDoctors = false;
          _isLoadingNews = false;
          _posts = List<Map<String, dynamic>>.from(_mockPosts);
        });
      }
    });
  }

  void _onScroll() {
    // Tương đương firstVisibleItemIndex > 3
    final show = _scrollController.offset > 400;
    if (show != _showBackToTop) setState(() => _showBackToTop = show);

    // Tương đương lastVisible >= total - 3
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() {
    if (_isLoadingMore || !_hasMorePosts) return;
    setState(() => _isLoadingMore = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _hasMorePosts = false;
        });
      }
    });
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

                //  SPECIALTIES
                SliverToBoxAdapter(
                  child:
                      _isLoadingSpecialties
                          ? const _SpecialtySkeletonList()
                          : SpecialtyList(
                            specialties: List<Map<String, dynamic>>.from(
                              _mockSpecialties,
                            ),
                            onTap:
                                (specialty) => Navigator.pushNamed(
                                  context,
                                  '/doctor-list',
                                  arguments: specialty,
                                ),
                          ),
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
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => PostCard(
                      post: _posts[i],
                      currentUserId: _mockUser['id'] ?? '',
                      onReport: () => _showReportDialog(context),
                      onDelete: () => _showDeleteDialog(context, i),
                      onNavigateToDetail:
                          () => Navigator.pushNamed(
                            context,
                            '/post-detail/${_posts[i]['id']}',
                          ),
                    ),
                    childCount: _posts.length,
                  ),
                ),

                SliverToBoxAdapter(child: _buildLoadMoreIndicator(context)),

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
    final avatarUrl = _mockUser['avatarURL'] ?? '';
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
                _mockUser['name'] ?? 'Người dùng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
            ],
          ),
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
              border: Border.all(
                color: Theme.of(context).colorScheme.onBackground,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(blurRadius: 8, color: Colors.black26),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                avatarUrl ?? 'assets/images/default_avatar.png',
                fit: BoxFit.cover,
                width: 50,
                height: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator(BuildContext context) {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasMorePosts && _posts.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('Đã hết bài viết')),
      );
    }
    return const SizedBox.shrink();
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Báo cáo bài viết'),
            content: const Text('Chọn lý do báo cáo'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Huỷ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Gửi'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Xoá bài viết'),
            content: const Text('Bạn có chắc muốn xoá?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Huỷ'),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _posts.removeAt(index));
                  Navigator.pop(context);
                },
                child: const Text('Xoá', style: TextStyle(color: Colors.red)),
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
