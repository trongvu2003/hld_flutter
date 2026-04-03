import 'package:flutter/material.dart';
import 'package:hld_flutter/theme/app_colors.dart';

class DoctorInfo {
  final String id;
  final String name;
  final String? avatarURL;
  final String? specialty;

  DoctorInfo({
    required this.id,
    required this.name,
    this.avatarURL,
    this.specialty,
  });
}

class PatientInfo {
  final String id;
  final String name;
  final String? avatarURL;

  PatientInfo({required this.id, required this.name, this.avatarURL});
}

class AppointmentResponse {
  final String id;
  final String date;
  final String time;
  final String status; // "pending" | "done" | "cancelled"
  final String? notes;
  final String? location;
  final DoctorInfo doctor;
  final PatientInfo patient;

  AppointmentResponse({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    this.notes,
    this.location,
    required this.doctor,
    required this.patient,
  });
}

final List<AppointmentResponse> mockUserAppointments = [
  AppointmentResponse(
    id: '1',
    date: '2025-06-15T08:00:00+07:00',
    time: '08:00',
    status: 'pending',
    notes: 'Khám định kỳ',
    location: 'TP. Hồ Chí Minh',
    doctor: DoctorInfo(
      id: 'd1',
      name: 'BS. Nguyễn Văn A',
      specialty: 'Tim mạch',
    ),
    patient: PatientInfo(id: 'p1', name: 'Trần Thị B'),
  ),
  AppointmentResponse(
    id: '2',
    date: '2025-05-10T10:00:00+07:00',
    time: '10:00',
    status: 'done',
    notes: 'Tái khám',
    location: 'Quận 1, TP. HCM',
    doctor: DoctorInfo(id: 'd2', name: 'BS. Lê Thị C', specialty: 'Da liễu'),
    patient: PatientInfo(id: 'p1', name: 'Trần Thị B'),
  ),
  AppointmentResponse(
    id: '3',
    date: '2025-04-20T14:00:00+07:00',
    time: '14:00',
    status: 'cancelled',
    notes: null,
    location: 'Quận 3, TP. HCM',
    doctor: DoctorInfo(
      id: 'd3',
      name: 'BS. Phạm Văn D',
      specialty: 'Nội tổng quát',
    ),
    patient: PatientInfo(id: 'p1', name: 'Trần Thị B'),
  ),
];

final List<AppointmentResponse> mockDoctorAppointments = [
  AppointmentResponse(
    id: '4',
    date: '2025-06-16T09:00:00+07:00',
    time: '09:00',
    status: 'pending',
    notes: 'Khám lần đầu',
    location: 'TP. Hồ Chí Minh',
    doctor: DoctorInfo(
      id: 'd1',
      name: 'BS. Nguyễn Văn A',
      specialty: 'Tim mạch',
    ),
    patient: PatientInfo(id: 'p2', name: 'Ngô Văn E'),
  ),
];

class AppointmentListScreen extends StatefulWidget {
  final String userRole;
  final String userId;

  const AppointmentListScreen({
    super.key,
    required this.userRole,
    required this.userId,
  });

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  // Tabs trạng thái
  int _selectedStatusTab = 0; // 0: Chờ khám, 1: Khám xong, 2: Đã huỷ
  final List<String> _statusTabs = ['Chờ khám', 'Khám xong', 'Đã huỷ'];

  // Tabs vai trò
  int _roleSelectedTab = 0; // 0: Đã đặt, 1: Được đặt
  final List<String> _roleTabs = ['Đã đặt', 'Được đặt'];

  bool _isLoading = false;

  // Dữ liệu (thay bằng state management thực tế: Provider/Riverpod/Bloc)
  List<AppointmentResponse> _userAppointments = mockUserAppointments;
  List<AppointmentResponse> _doctorAppointments = mockDoctorAppointments;

  bool get _isPatient => widget.userRole == 'User';

  bool get _isDoctor => widget.userRole == 'Doctor';

  @override
  void initState() {
    super.initState();
    _roleSelectedTab = _isDoctor ? 1 : 0;
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoading = true);
    // TODO: Gọi API thực tế ở đây
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  List<AppointmentResponse> get _currentRoleAppointments {
    return _roleSelectedTab == 0 ? _userAppointments : _doctorAppointments;
  }

  List<AppointmentResponse> get _filteredAppointments {
    final statusMap = {0: 'pending', 1: 'done', 2: 'cancelled'};
    final targetStatus = statusMap[_selectedStatusTab] ?? 'pending';
    return _currentRoleAppointments
        .where((a) => a.status == targetStatus)
        .toList();
  }

  void _cancelAppointment(String appointmentId) {
    setState(() {
      final list =
          _roleSelectedTab == 0 ? _userAppointments : _doctorAppointments;
      final index = list.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        final updated = AppointmentResponse(
          id: list[index].id,
          date: list[index].date,
          time: list[index].time,
          status: 'cancelled',
          notes: list[index].notes,
          location: list[index].location,
          doctor: list[index].doctor,
          patient: list[index].patient,
        );
        if (_roleSelectedTab == 0) {
          _userAppointments = List.from(_userAppointments)..[index] = updated;
        } else {
          _doctorAppointments = List.from(_doctorAppointments)
            ..[index] = updated;
        }
      }
    });
    // TODO: Gọi API cancelAppointment(appointmentId, userId)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã huỷ lịch hẹn')));
  }

  void _deleteAppointment(String appointmentId) {
    setState(() {
      if (_roleSelectedTab == 0) {
        _userAppointments =
            _userAppointments.where((a) => a.id != appointmentId).toList();
      } else {
        _doctorAppointments =
            _doctorAppointments.where((a) => a.id != appointmentId).toList();
      }
    });
    // TODO: Gọi API deleteAppointment(appointmentId, userId)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xoá lịch hẹn')));
  }

  void _navigateToEdit(AppointmentResponse appointment) {
    // TODO: Navigate với args tương ứng
    // Navigator.pushNamed(context, '/appointment-detail', arguments: {...})
    debugPrint('Navigate chỉnh sửa lịch hẹn: ${appointment.id}');
  }

  void _navigateToRebook(AppointmentResponse appointment) {
    debugPrint('Navigate đặt lại: ${appointment.doctor.id}');
  }

  void _navigateToRating(AppointmentResponse appointment) {
    debugPrint('Navigate đánh giá bác sĩ: ${appointment.doctor.id}');
  }

  void _navigateToServiceSelection(AppointmentResponse appointment) {
    debugPrint('Navigate chọn dịch vụ: ${appointment.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Column(
        children: [
          //Header
          _buildHeader(context),

          //Body
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Tabs vai trò
                  _buildRoleTabsRow(context),

                  // Dropdown trạng thái
                  _buildStatusDropdown(context),

                  // Danh sách lịch hẹn
                  Expanded(
                    child:
                        _isLoading
                            ? _buildSkeletonList()
                            : _buildAppointmentList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header
  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 64,
        width: double.infinity,
        alignment: Alignment.center,
        color: AppColors.lightTheme,
        child: Text(
          'Danh sách lịch hẹn',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.black,
            fontSize: 23
          ),
        ),
      ),
    );
  }

  // ── Role Tabs ──
  Widget _buildRoleTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TabBar(
        controller: TabController(
          length: 2,
          vsync: Scaffold.of(context),
          initialIndex: _roleSelectedTab,
        )..addListener(() {}),
        // Dùng DefaultTabController để đơn giản hơn, xem bên dưới
        tabs: const [],
      ),
    );
  }

  // Dùng Row thay vì TabBar để dễ control hơn
  Widget _buildRoleTabsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: List.generate(_roleTabs.length, (index) {
          final bool isEnabled =
              _isPatient ? index == 0 : true; // Patient chỉ xem "Đã đặt"
          final bool isSelected = _roleSelectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap:
                  isEnabled
                      ? () => setState(() => _roleSelectedTab = index)
                      : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.grey.shade200
                          : isEnabled
                          ? Colors.white
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      isSelected
                          ? Border(
                            bottom: BorderSide(
                              color: AppColors.lightTheme,
                              width: 2,
                            ),
                          )
                          : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  _roleTabs[index],
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isSelected
                            ? AppColors.lightTheme
                            : isEnabled
                            ? Colors.black
                            : Colors.black,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  //  Status Dropdown
  Widget _buildStatusDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(0.8),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedStatusTab,
            isExpanded: true,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            borderRadius: BorderRadius.circular(8),
            dropdownColor: Colors.white,
            onChanged: (val) {
              if (val != null) setState(() => _selectedStatusTab = val);
            },
            items: List.generate(
              _statusTabs.length,
              (i) => DropdownMenuItem(
                value: i,
                child: Text(
                  _statusTabs[i],
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Appointment List
  Widget _buildAppointmentList() {
    final appointments = _filteredAppointments;
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'Không có lịch hẹn nào',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: appointments.length,
      itemBuilder:
          (_, i) => AppointmentCard(
            appointment: appointments[i],
            userId: widget.userId,
            selectedStatusTab: _selectedStatusTab,
            roleSelectedTab: _roleSelectedTab,
            onCancel: () => _cancelAppointment(appointments[i].id),
            onDelete: () => _deleteAppointment(appointments[i].id),
            onEdit: () => _navigateToEdit(appointments[i]),
            onRebook: () => _navigateToRebook(appointments[i]),
            onRate: () => _navigateToRating(appointments[i]),
            onComplete: () => _navigateToServiceSelection(appointments[i]),
          ),
    );
  }

  // ── Skeleton List ──
  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => const AppointmentSkeletonItem(),
    );
  }

  // Override build để dùng _buildRoleTabsRow thay vì TabBar
  @override
  Widget build2(BuildContext context) => build(context);
}

// Sửa lại build để bỏ TabController phức tạp
class _FixedAppointmentListScreen extends _AppointmentListScreenState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  _buildRoleTabsRow(context),
                  _buildStatusDropdown(context),
                  Expanded(
                    child:
                        _isLoading
                            ? _buildSkeletonList()
                            : _buildAppointmentList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class AppointmentCard extends StatelessWidget {
  final AppointmentResponse appointment;
  final String userId;
  final int selectedStatusTab;
  final int roleSelectedTab;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onRebook;
  final VoidCallback onRate;
  final VoidCallback onComplete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.userId,
    required this.selectedStatusTab,
    required this.roleSelectedTab,
    required this.onCancel,
    required this.onDelete,
    required this.onEdit,
    required this.onRebook,
    required this.onRate,
    required this.onComplete,
  });

  bool get isDoctor => roleSelectedTab == 1;

  bool get isPatient => roleSelectedTab == 0;

  String get avatarUrl =>
      isDoctor
          ? (appointment.patient.avatarURL ?? '')
          : (appointment.doctor.avatarURL ?? '');

  String get displayName =>
      isDoctor ? appointment.patient.name : appointment.doctor.name;

  String get specialtyText =>
      isDoctor ? 'Bệnh nhân' : (appointment.doctor.specialty ?? 'Bác sĩ');

  String get formattedDate {
    try {
      final dt = DateTime.parse(appointment.date).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return 'Ngày không hợp lệ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedCornerShape(16),
      elevation: 4,
      color: Theme.of(context).colorScheme.onPrimary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$formattedDate | ${appointment.time}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(height: 24, thickness: 0.5, color: Colors.grey),
            // Avatar + Thông tin
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                Expanded(child: _buildInfo(context)),
              ],
            ),

            const SizedBox(height: 12),

            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(
                  context,
                ).style.copyWith(fontSize: 14),
                children: [
                  const TextSpan(
                    text: 'Ghi chú: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: appointment.notes ?? 'Không có'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Buttons
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipOval(
      child:
          avatarUrl.isNotEmpty
              ? Image.network(
                avatarUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _defaultAvatar(),
              )
              : _defaultAvatar(),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 48, color: Colors.grey.shade400),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          specialtyText,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                appointment.location ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    if (isDoctor) {
      return _buildDoctorButtons(context);
    } else if (isPatient) {
      return _buildPatientButtons(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildDoctorButtons(BuildContext context) {
    if (selectedStatusTab == 0) {
      // Chờ khám
      return Row(
        children: [
          Expanded(child: _OutlineBtn(label: 'Hủy', onTap: onCancel)),
          const SizedBox(width: 12),
          Expanded(child: _DarkBtn(label: 'Hoàn thành', onTap: onComplete)),
        ],
      );
    } else {
      // Khám xong hoặc Đã huỷ
      return _OutlineBtn(label: 'Xóa', onTap: onDelete, fullWidth: true);
    }
  }

  Widget _buildPatientButtons(BuildContext context) {
    if (selectedStatusTab == 0) {
      // Chờ khám
      return Row(
        children: [
          Expanded(child: _OutlineBtn(label: 'Huỷ', onTap: onCancel)),
          const SizedBox(width: 12),
          Expanded(child: _DarkBtn(label: 'Chỉnh sửa', onTap: onEdit)),
        ],
      );
    } else if (selectedStatusTab == 1) {
      // Khám xong
      return Row(
        children: [
          Expanded(child: _OutlineBtn(label: 'Xóa', onTap: onDelete)),
          const SizedBox(width: 8),
          Expanded(child: _DarkBtn(label: 'Đặt lại', onTap: onRebook)),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: onRate,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.tertiaryContainer,
                shape: RoundedCornerShape(8),
              ),
              child: const Text('Đánh giá'),
            ),
          ),
        ],
      );
    } else if (selectedStatusTab == 2) {
      // Đã huỷ
      return Row(
        children: [
          Expanded(child: _OutlineBtn(label: 'Xóa', onTap: onDelete)),
          const SizedBox(width: 12),
          Expanded(child: _DarkBtn(label: 'Đặt lại', onTap: onRebook)),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

// Helper: Bo góc dùng như RoundedCornerShape
class RoundedCornerShape extends RoundedRectangleBorder {
  RoundedCornerShape(double radius)
    : super(borderRadius: BorderRadius.circular(radius));
}


class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;

  const _OutlineBtn({
    required this.label,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final btn = OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFFE0E0E0),
        foregroundColor: Colors.black,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class _DarkBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DarkBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}

// SKELETON ITEM

class AppointmentSkeletonItem extends StatelessWidget {
  const AppointmentSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBox(width: 150, height: 20),
            const SizedBox(height: 12),
            Row(
              children: [
                _SkeletonBox(width: 80, height: 80, isCircle: true),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 150, height: 20),
                    const SizedBox(height: 8),
                    _SkeletonBox(width: 180, height: 16),
                    const SizedBox(height: 8),
                    _SkeletonBox(width: 120, height: 16),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SkeletonBox(width: 100, height: 36),
                _SkeletonBox(width: 100, height: 36),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final bool isCircle;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.isCircle = false,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder:
          (_, __) => Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(_animation.value),
              borderRadius:
                  widget.isCircle
                      ? BorderRadius.circular(widget.width / 2)
                      : BorderRadius.circular(4),
            ),
          ),
    );
  }
}

// ==================== MAIN (để test standalone) ====================

void main() {
  runApp(const _TestApp());
}

class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: _AppointmentListScreenFixed(
        userRole: 'User', // Đổi thành 'Doctor' để test role khác
        userId: 'test-user-id',
      ),
    );
  }
}

// Wrapper đúng sử dụng StatefulWidget pattern không cần TabController
class _AppointmentListScreenFixed extends StatefulWidget {
  final String userRole;
  final String userId;

  const _AppointmentListScreenFixed({
    required this.userRole,
    required this.userId,
  });

  @override
  State<_AppointmentListScreenFixed> createState() =>
      _AppointmentListScreenFixedState();
}

class _AppointmentListScreenFixedState
    extends State<_AppointmentListScreenFixed> {
  int _selectedStatusTab = 0;
  final List<String> _statusTabs = ['Chờ khám', 'Khám xong', 'Đã huỷ'];

  int _roleSelectedTab = 0;
  final List<String> _roleTabs = ['Đã đặt', 'Được đặt'];

  bool _isLoading = false;

  List<AppointmentResponse> _userAppointments = mockUserAppointments;
  List<AppointmentResponse> _doctorAppointments = mockDoctorAppointments;

  bool get _isPatient => widget.userRole == 'User';

  bool get _isDoctor => widget.userRole == 'Doctor';

  @override
  void initState() {
    super.initState();
    _roleSelectedTab = _isDoctor ? 1 : 0;
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _isLoading = false);
  }

  List<AppointmentResponse> get _currentList =>
      _roleSelectedTab == 0 ? _userAppointments : _doctorAppointments;

  List<AppointmentResponse> get _filtered {
    final map = {0: 'pending', 1: 'done', 2: 'cancelled'};
    return _currentList
        .where((a) => a.status == map[_selectedStatusTab])
        .toList();
  }

  void _cancel(String id) {
    _mutate(id, (a) => _copy(a, status: 'cancelled'));
    _snack('Đã huỷ lịch hẹn');
  }

  void _delete(String id) {
    setState(() {
      if (_roleSelectedTab == 0) {
        _userAppointments = _userAppointments.where((a) => a.id != id).toList();
      } else {
        _doctorAppointments =
            _doctorAppointments.where((a) => a.id != id).toList();
      }
    });
    _snack('Đã xoá lịch hẹn');
  }

  void _mutate(
    String id,
    AppointmentResponse Function(AppointmentResponse) fn,
  ) {
    setState(() {
      if (_roleSelectedTab == 0) {
        _userAppointments =
            _userAppointments.map((a) => a.id == id ? fn(a) : a).toList();
      } else {
        _doctorAppointments =
            _doctorAppointments.map((a) => a.id == id ? fn(a) : a).toList();
      }
    });
  }

  AppointmentResponse _copy(AppointmentResponse a, {String? status}) {
    return AppointmentResponse(
      id: a.id,
      date: a.date,
      time: a.time,
      status: status ?? a.status,
      notes: a.notes,
      location: a.location,
      doctor: a.doctor,
      patient: a.patient,
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Container(
              height: 64,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                'Danh sách lịch hẹn',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),

          // Body
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Role Tabs
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: List.generate(_roleTabs.length, (index) {
                        final bool enabled = _isPatient ? index == 0 : true;
                        final bool selected = _roleSelectedTab == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap:
                                enabled
                                    ? () =>
                                        setState(() => _roleSelectedTab = index)
                                    : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    enabled
                                        ? Colors.transparent
                                        : Theme.of(
                                          context,
                                        ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    selected
                                        ? Border(
                                          bottom: BorderSide(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            width: 2,
                                          ),
                                        )
                                        : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _roleTabs[index],
                                style: TextStyle(
                                  fontWeight:
                                      selected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color:
                                      selected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : enabled
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onBackground
                                          : Theme.of(context)
                                              .colorScheme
                                              .onBackground
                                              .withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Status Dropdown
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedStatusTab,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          borderRadius: BorderRadius.circular(8),
                          dropdownColor:
                              Theme.of(context).colorScheme.background,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedStatusTab = val);
                            }
                          },
                          items: List.generate(
                            _statusTabs.length,
                            (i) => DropdownMenuItem(
                              value: i,
                              child: Text(
                                _statusTabs[i],
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onBackground,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // List
                  Expanded(
                    child:
                        _isLoading
                            ? ListView.builder(
                              itemCount: 5,
                              itemBuilder:
                                  (_, __) => const AppointmentSkeletonItem(),
                            )
                            : _filtered.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 64,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Không có lịch hẹn nào',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: _filtered.length,
                              itemBuilder:
                                  (_, i) => AppointmentCard(
                                    appointment: _filtered[i],
                                    userId: widget.userId,
                                    selectedStatusTab: _selectedStatusTab,
                                    roleSelectedTab: _roleSelectedTab,
                                    onCancel: () => _cancel(_filtered[i].id),
                                    onDelete: () => _delete(_filtered[i].id),
                                    onEdit:
                                        () => debugPrint(
                                          'Edit ${_filtered[i].id}',
                                        ),
                                    onRebook:
                                        () => debugPrint(
                                          'Rebook ${_filtered[i].id}',
                                        ),
                                    onRate:
                                        () => debugPrint(
                                          'Rate ${_filtered[i].id}',
                                        ),
                                    onComplete:
                                        () => debugPrint(
                                          'Complete ${_filtered[i].id}',
                                        ),
                                  ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
