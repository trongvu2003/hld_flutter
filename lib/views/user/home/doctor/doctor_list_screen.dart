import 'package:flutter/material.dart';
import 'package:hld_flutter/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../../models/responsemodel/doctor.dart';
import '../../../../viewmodels/specialty_viewmodel.dart';

class DoctorListScreen extends StatefulWidget {
  final String specialtyId;
  final String specialtyName;
  final String specialtyDesc;

  const DoctorListScreen({
    super.key,
    required this.specialtyId,
    required this.specialtyName,
    required this.specialtyDesc,
  });

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpecialtyViewModel>().fetchSpecialtyDoctor(
        widget.specialtyId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SpecialtyViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          _TopBar(
            onBack: () => Navigator.pop(context),
            onSearch: (query) => vm.filterDoctorsByLocation(query),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.lightTheme.withOpacity(0.5),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.specialtyName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.specialtyDesc,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onBackground,
                    ),
                    maxLines: _isExpanded ? null : 3,
                    overflow:
                        _isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                  ),
                  if (widget.specialtyDesc.length > 100)
                    GestureDetector(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _isExpanded ? 'Thu gọn' : 'Xem thêm',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _isExpanded ? Colors.grey : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          Expanded(
            child:
                vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.filteredDoctors.isEmpty
                    ? Center(
                      child: Text(
                        'Không tìm thấy bác sĩ trong chuyên khoa này',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: vm.filteredDoctors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _DoctorItem(
                          doctor: vm.filteredDoctors[index],
                          specialtyName: widget.specialtyName,
                          onBooking: (doctorId) {
                            Navigator.pushNamed(
                              context,
                              '/other_user_profile',
                              arguments: {'doctorId': doctorId},
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<String> onSearch;

  const _TopBar({required this.onBack, required this.onSearch});

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 8,
      color: AppColors.lightTheme,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tìm bác sĩ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 52,
                child: TextField(
                  controller: _searchController,
                  onChanged: widget.onSearch,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    hintText: 'Nhập địa chỉ, ví dụ: HCM',
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: colorScheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorItem extends StatelessWidget {
  final Doctor doctor;
  final String specialtyName;
  final ValueChanged<String> onBooking;

  const _DoctorItem({
    required this.doctor,
    required this.specialtyName,
    required this.onBooking,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPaused = doctor.isClinicPaused ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.lightTheme.withOpacity(0.5),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child:
                      doctor.avatarURL != null && doctor.avatarURL!.isNotEmpty
                          ? Image.network(
                            doctor.avatarURL!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => ClipOval(
                                  child: Image.asset(
                                    'assets/images/avatar_doctor.jpg',
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          )
                          : ClipOval(
                            child: Image.asset(
                              'assets/images/avatar_doctor.jpg',
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                ),

                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Bác sĩ',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                          if (isPaused) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Tạm ngưng nhận lịch',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        specialtyName,
                        style: TextStyle(
                          fontSize: 15,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.location_on, size: 18, color: Colors.black.withOpacity(0.8)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    doctor.address ?? 'Chưa cập nhật địa chỉ',
                    style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.8)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () => onBooking(doctor.id),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lightTheme,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                ),
                child: Text(
                  'Đặt lịch khám',
                  style: TextStyle(
                    fontSize: 12,
                    color:Colors.black,fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

