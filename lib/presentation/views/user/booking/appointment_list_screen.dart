import 'package:flutter/material.dart';
import 'package:hld_flutter/routes/app_routes.dart';
import 'package:hld_flutter/presentation/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/responsemodel/appointment.dart';
import '../../../viewmodels/appointment_viewmodel.dart';
import '../../skeleton/skeleton_box.dart';
import '../../widgets/app_dialog.dart';
import 'widgets/appointment_card.dart';

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
  List<AppointmentResponse> userAppointments = [];
  List<AppointmentResponse> doctorAppointments = [];

  bool get _isPatient => widget.userRole == 'User';

  bool get _isDoctor => widget.userRole == 'Doctor';

  @override
  void initState() {
    super.initState();
    _roleSelectedTab = _isDoctor ? 1 : 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.userId.isNotEmpty) {
        context.read<AppointmentViewModel>().getAppointmentUser(widget.userId);
        context.read<AppointmentViewModel>().getAppointmentDoctor(
          widget.userId,
        );
      } else {
        debugPrint("Lỗi: widget.userId bị rỗng!");
      }
    });
  }

  void _cancelAppointment(String appointmentId) async {
    AppDialog.show(
      context: context,
      title: 'Huỷ lịch hẹn',
      content:
          'Bạn có chắc chắn muốn huỷ lịch hẹn này không? Hành động này không thể hoàn tác.',
      cancelText: 'Đóng',
      cancelBgColor: Colors.grey[200],
      cancelColor: Colors.black87,
      confirmText: 'Huỷ lịch',
      confirmBgColor: Colors.red,
      confirmColor: Colors.white,
      onConfirm: () async {
        final vm = context.read<AppointmentViewModel>();
        final isSuccess = await vm.cancelAppointment(appointmentId);

        if (!mounted) return;

        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã huỷ lịch hẹn thành công'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Huỷ lịch thất bại: ${vm.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _deleteAppointment(String appointmentId) {
    AppDialog.show(
      context: context,
      title: 'Xoá lịch hẹn',
      content: 'Bạn có chắc chắn muốn xoá lịch hẹn này khỏi danh sách không?',
      confirmText: 'Xoá',
      confirmBgColor: Colors.red,
      confirmColor: Colors.white,
      onConfirm: () async {
        final vm = context.read<AppointmentViewModel>();
        final success = await vm.deleteAppointmentById(appointmentId);

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xoá lịch hẹn thành công'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xoá thất bại: ${vm.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _navigateToEdit(AppointmentResponse appointment) {
    final doctor = appointment.doctor;
    Navigator.pushNamed(
      context,
      AppRoutes.appointmentdetailscreen,
      arguments: {
        'isEditMode': true,
        'appointmentId': appointment.id,
        'doctorId': doctor.id,
        'doctorName': doctor.name,
        'doctorAvatar': doctor.avatarURL,
        'specialtyName': doctor.specialty,
        'doctorAddress': appointment.location,
        'hasHomeService': true,
        'selectedDate': appointment.date,
        'selectedTime': appointment.time,
        'notes': appointment.notes,
        'location': appointment.location,
        'method': appointment.examinationMethod,
      },
    );

    debugPrint('Điều hướng chỉnh sửa lịch hẹn: ${appointment.id}');
  }

  void _navigateToRebook(AppointmentResponse appointment) {
    final doctor = appointment.doctor;
    Navigator.pushNamed(
      context,
      AppRoutes.appointmentdetailscreen,
      arguments: {
        'appointmentId': appointment.id,
        'doctorId': doctor.id,
        'doctorName': doctor.name,
        'doctorAvatar': doctor.avatarURL,
        'specialtyName': doctor.specialty,
        'doctorAddress': appointment.location,
        'hasHomeService': true,
        'selectedDate': appointment.date,
        'selectedTime': appointment.time,
        'notes': appointment.notes,
        'location': appointment.location,
        'method': appointment.examinationMethod,
      },
    );
    debugPrint('Navigate đặt lại: ${appointment.doctor.id}');
  }

  void _navigateToRating(AppointmentResponse appointment) {
    Navigator.pushNamed(
      context,
      AppRoutes.otheruserprofile,
      arguments: {
        'doctorId': appointment.doctor.id,
        'currentUserId': widget.userId,
        'initialTabIndex': 1,
      },
    );
  }

  void _navigateToServiceSelection(AppointmentResponse appointment) {
    debugPrint('Tên bệnh nhân: ${appointment.patient.name}');
    Navigator.pushNamed(
      context,
      AppRoutes.serviceselection,
      arguments: {
        'appointmentId': appointment.id,
        'patientName': appointment.patient.name,
        'doctorId': appointment.doctor.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.lightTheme,
        body: Column(
          children: [
            //Header
            _buildHeader(context),
            //Body
            Expanded(
              child: Consumer<AppointmentViewModel>(
                builder: (context, vm, child) {
                  return Container(
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
                              vm.isLoading
                                  ? _buildSkeletonList()
                                  : _buildAppointmentList(vm),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
            fontSize: 23,
          ),
        ),
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
          border: Border.all(color: Colors.black.withOpacity(0.8)),
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
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Appointment List
  Widget _buildAppointmentList(AppointmentViewModel vm) {
    // Map index của Dropdown với status trả về từ API
    final statusMap = {0: 'pending', 1: 'done', 2: 'cancelled'};
    final targetStatus = statusMap[_selectedStatusTab] ?? 'pending';

    // Thực hiện LỌC dữ liệu
    final List<AppointmentResponse> sourceList =
        _roleSelectedTab == 0 ? vm.appointments : vm.appointmentsfordoctor;
    final filteredAppointments =
        sourceList.where((a) {
          return a.status == targetStatus;
        }).toList();
    // Render UI bằng danh sách ĐÃ LỌC
    if (filteredAppointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await vm.getAppointmentUser(widget.userId);
          await vm.getAppointmentDoctor(widget.userId);
        },
        child: ListView(
          // Đổi Center thành ListView để có thể kéo được
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            const Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Không có lịch hẹn nào',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await vm.getAppointmentUser(widget.userId);
        await vm.getAppointmentDoctor(widget.userId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: filteredAppointments.length,
        itemBuilder:
            (_, i) => AppointmentCard(
              appointment: filteredAppointments[i],
              userId: widget.userId,
              selectedStatusTab: _selectedStatusTab,
              roleSelectedTab: _roleSelectedTab,
              onCancel: () => _cancelAppointment(filteredAppointments[i].id),
              onDelete: () => _deleteAppointment(filteredAppointments[i].id),
              onEdit: () => _navigateToEdit(filteredAppointments[i]),
              onRebook: () => _navigateToRebook(filteredAppointments[i]),
              onRate: () => _navigateToRating(filteredAppointments[i]),
              onComplete:
                  () => _navigateToServiceSelection(filteredAppointments[i]),
            ),
      ),
    );
  }

  // Skeleton List
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
            Skeleton(width: 150, height: 20),
            const SizedBox(height: 12),
            Row(
              children: [
                Skeleton(width: 80, height: 80),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 150, height: 20),
                    const SizedBox(height: 8),
                    Skeleton(width: 180, height: 16),
                    const SizedBox(height: 8),
                    Skeleton(width: 120, height: 16),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton(width: 100, height: 36),
                Skeleton(width: 100, height: 36),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
