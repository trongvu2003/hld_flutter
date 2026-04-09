import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hld_flutter/theme/app_colors.dart';
import 'package:hld_flutter/views/user/home/doctor/widgets/view_introduce.dart';
import 'package:provider/provider.dart';
import '../../../../models/responsemodel/doctor.dart';
import '../../../../routes/app_routes.dart';
import '../../../../viewmodels/doctor_viewmodel.dart';
import '../../../skeleton/skeleton_box.dart';
import 'widgets/other_posts_tab.dart';
import 'widgets/view_rating.dart';

class DoctorScreen extends StatefulWidget {
  final String doctorId;
  final String currentUserId;

  const DoctorScreen({
    super.key,
    required this.doctorId,
    required this.currentUserId,
  });

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showWriteReviewScreen = false;
  bool _isLoading = false;
  GetDoctorResponse? _doctor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    setState(() => _isLoading = true);
    final doctorVM = context.read<DoctorViewModel>();
    final doctor = await doctorVM.getDoctorById(widget.doctorId);

    setState(() {
      _doctor = doctor;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _doctor == null) {
      return _buildDoctorSkeleton(context);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomBar(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: UserInfoHeader(
                doctor: _doctor!,
                onBack: () => Navigator.pop(context),
                onMoreTap: () {},
                onImageClick: (url) {},
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.lightTheme,
                  unselectedLabelColor: Colors.black.withOpacity(0.7),
                  indicatorColor: AppColors.lightTheme,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: "Thông tin"),
                    Tab(text: "Đánh giá"),
                    Tab(text: "Bài viết"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [_buildInfoTab(), _buildReviewTab(), _buildPostTab()],
        ),
      ),
    );
  }

  Widget? _buildBottomBar() {
    if (_showWriteReviewScreen) return null;

    if (_tabController.index == 0 && _doctor!.id != widget.currentUserId) {
      return BookingButton(doctor: _doctor!);
    } else if (_tabController.index == 1) {
      return WriteReviewButton(
        onClick: () => setState(() => _showWriteReviewScreen = true),
      );
    }
    return null;
  }

  Widget _buildInfoTab() {
    return ViewIntroduce(
      doctor: _doctor!,
      onImageClick: (url) {
        _openImageDialog(context, url);
      },
    );
  }

  Widget _buildReviewTab() {
    return ReviewTab(
      doctorId: _doctor!.id,
      currentUserId: widget.currentUserId,
    );
  }

  Widget _buildPostTab() {
    return PostsTab(userID: _doctor!.id, currentUserId: widget.currentUserId);
  }
}

class UserInfoHeader extends StatelessWidget {
  final GetDoctorResponse doctor;
  final VoidCallback onBack;
  final VoidCallback onMoreTap;
  final Function(String) onImageClick;

  const UserInfoHeader({
    super.key,
    required this.doctor,
    required this.onBack,
    required this.onMoreTap,
    required this.onImageClick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 290,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 200,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: CachedNetworkImage(
                    imageUrl: doctor.avatarURL!,
                    fit: BoxFit.cover,
                    errorWidget:
                        (context, url, error) => Container(color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.lightTheme.withOpacity(0.6),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: onBack,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: AppColors.lightTheme.withOpacity(0.6),
                      child: IconButton(
                        icon: Icon(Icons.more_vert, color: Colors.black),
                        onPressed: onMoreTap,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 210,
                left: 150,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      doctor.specialty.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTheme,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 140,
                left: 20,
                child: GestureDetector(
                  onTap: () => onImageClick(doctor.avatarURL!),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8),
                      ],
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(doctor.avatarURL!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoStatItem(
                  label: "Kinh nghiệm",
                  value: "${doctor.experience ?? 0} năm",
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                _InfoStatItem(
                  label: "Bệnh nhân",
                  value: doctor.patientsCount.toString(),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                _InfoStatItem(
                  label: "Đánh giá",
                  value: doctor.ratingsCount.toString(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoStatItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoStatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.lightTheme,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// BUTTONS
class BookingButton extends StatelessWidget {
  final GetDoctorResponse doctor;

  const BookingButton({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final bool isPaused = doctor.isClinicPaused ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ElevatedButton(
        onPressed:
            isPaused
                ? null
                : () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.appointmentdetailscreen,
                    arguments: {
                      'doctorId': doctor.id,
                      'doctorName': doctor.name,
                      'doctorAddress': doctor.address,
                      'doctorAvatar': doctor.avatarURL,
                      'specialtyName': doctor.specialty.name,
                      'hasHomeService': doctor.hasHomeService,
                    },
                  );
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: isPaused ? Colors.grey : AppColors.lightTheme,
          foregroundColor: isPaused ? Colors.black38 : Colors.black,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          isPaused ? "Tạm ngưng nhận lịch" : "Đặt khám",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class WriteReviewButton extends StatelessWidget {
  final VoidCallback onClick;

  const WriteReviewButton({super.key, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ElevatedButton(
        onPressed: onClick,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.onBackground,
          foregroundColor: Theme.of(context).colorScheme.background,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text("Viết đánh giá", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

void _openImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder:
        (_) => GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: InteractiveViewer(
                child: Hero(
                  tag: imageUrl,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) =>
                            const Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
  );
}

Widget _buildDoctorSkeleton(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton (Ảnh bìa + Avatar)
          SizedBox(
            height: 290,
            child: Stack(
              children: [
                Skeleton(width: double.infinity, height: 200), // Banner
                Positioned(
                  top: 140,
                  left: 20,
                  child: Skeleton(
                    width: 120,
                    height: 120,
                    radius: 60,
                  ), // Avatar
                ),
                Positioned(
                  top: 210,
                  left: 150,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: 150, height: 24, radius: 4),
                      // Tên
                      const SizedBox(height: 8),
                      Skeleton(width: 100, height: 16, radius: 4),
                      // Chuyên khoa
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stat Bar Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3,
                  (index) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Skeleton(width: 40, height: 20, radius: 4),
                      const SizedBox(height: 4),
                      Skeleton(width: 60, height: 12, radius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // TabBar Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                3,
                (index) => Skeleton(width: 80, height: 30, radius: 15),
              ),
            ),
          ),

          // Content Skeleton
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 120, height: 20, radius: 4),
                const SizedBox(height: 12),
                Skeleton(width: double.infinity, height: 100, radius: 8),
                const SizedBox(height: 20),
                Skeleton(width: 150, height: 20, radius: 4),
                const SizedBox(height: 12),
                Skeleton(width: double.infinity, height: 150, radius: 8),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
