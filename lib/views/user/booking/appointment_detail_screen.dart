import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../viewmodels/user_viewmodel.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final bool isEditing;
  final String? appointmentId;
  final String doctorId;
  final String doctorName;
  final String doctorAddress;
  final String doctorAvatar;
  final String specialtyName;
  final bool hasHomeService;

  // Dùng cho chế độ Edit
  final String? initialDate;
  final String? initialTime;
  final String? initialNotes;
  final String? initialMethod;

  const AppointmentDetailScreen({
    super.key,
    this.isEditing = false,
    this.appointmentId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorAddress,
    required this.doctorAvatar,
    required this.specialtyName,
    required this.hasHomeService,
    this.initialDate,
    this.initialTime,
    this.initialNotes,
    this.initialMethod,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  String examinationMethod = '';
  String notes = '';
  String date = '';
  String time = '';

  // Controller giữ ổn định, không tạo lại mỗi build
  late final TextEditingController _notesController;

  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      examinationMethod = widget.initialMethod ?? '';
      notes = widget.initialNotes ?? '';
      date = widget.initialDate ?? '';
      time = widget.initialTime ?? '';
    }
    _notesController = TextEditingController(text: notes);
    _notesController.addListener(() {
      notes = _notesController.text;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserViewModel>().loadUser();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Thiếu thông tin'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _navigateToCalendar() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.bookingcalendar,
      arguments: {'doctorId': widget.doctorId},
    );

    if (result != null && result is Map) {
      final safeResult = Map<String, dynamic>.from(result);

      setState(() {
        date = safeResult['date']?.toString() ?? date;
        time = safeResult['time']?.toString() ?? time;
      });
    }
  }

  void _onSubmit() {
    if (examinationMethod.isEmpty) {
      _showErrorDialog('Vui lòng chọn hình thức khám');
      return;
    }
    if (date.isEmpty || time.isEmpty) {
      _showErrorDialog('Vui lòng chọn ngày giờ khám');
      return;
    }

    if (widget.isEditing) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật lịch hẹn!')));
      Navigator.pop(context);
    } else {
      final user = context.read<UserViewModel>().user;
      Navigator.pushNamed(
        context,
        '/booking-confirm',
        arguments: {
          'examinationMethod': examinationMethod,
          'notes': notes,
          'date': date,
          'time': time,
          'doctorId': widget.doctorId,
          'doctorName': widget.doctorName,
          'doctorAddress': widget.doctorAddress,
          'specialtyName': widget.specialtyName,
          'patientID': user!.id ?? "",
          'patientName': user.name ?? "",
          'patientPhone': user.phone ?? "",
          'patientAddress': user.address ?? "",
          'patientModel': user.role ?? 'User',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();
    final user = vm.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final title =
        widget.isEditing ? 'Chỉnh sửa lịch hẹn khám' : 'Chi tiết lịch hẹn khám';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _TopBar(title: title, onBack: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 12),
          _DoctorInfoSection(
            doctorName: widget.doctorName,
            doctorAvatar: widget.doctorAvatar,
            specialtyName: widget.specialtyName,
          ),
          const SizedBox(height: 40),
          _PatientInfoSection(
            patientName: user!.name ?? 'Chưa cập nhật',
            patientPhone: user!.phone ?? 'Chưa cập nhật',
          ),

          const SizedBox(height: 12),
          _VisitMethodSection(
            examinationMethod: examinationMethod,
            doctorAddress: widget.doctorAddress,
            patientAddress: user.address ?? 'Chưa có địa chỉ',
            hasHomeService: widget.hasHomeService,
            onMethodChanged: (m) => setState(() => examinationMethod = m),
          ),
          const SizedBox(height: 12),
          _AppointmentDateSection(
            date: date,
            time: time,
            onTap: _navigateToCalendar,
          ),
          const SizedBox(height: 12),
          _NoteToDoctorSection(controller: _notesController),
          const SizedBox(height: 12),
          const _FeeSummarySection(),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightTheme,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _onSubmit,
              child: Text(
                widget.isEditing ? 'Cập nhật lịch hẹn' : 'Đặt dịch vụ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Kotlin: Spacer 60dp sau button
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

//  TOP BAR
class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        color: AppColors.lightTheme,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 24,
                    ),
                    onPressed: onBack,
                  ),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//  DOCTOR INFO
class _DoctorInfoSection extends StatelessWidget {
  final String doctorName;
  final String doctorAvatar;
  final String specialtyName;

  const _DoctorInfoSection({
    required this.doctorName,
    required this.doctorAvatar,
    required this.specialtyName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              doctorAvatar.isNotEmpty
                  ? doctorAvatar
                  : 'https://via.placeholder.com/120',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Image.asset(
                    'assets/images/avatar_doctor.jpg',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bác sĩ',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  doctorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  specialtyName,
                  style: TextStyle(color: Colors.black.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  PATIENT INFO
class _PatientInfoSection extends StatefulWidget {
  final String patientName;
  final String patientPhone;

  const _PatientInfoSection({
    required this.patientName,
    required this.patientPhone,
  });

  @override
  State<_PatientInfoSection> createState() => _PatientInfoSectionState();
}

class _PatientInfoSectionState extends State<_PatientInfoSection> {
  void _showDetailDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Chi tiết hồ sơ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _InfoRow(label: 'Họ và tên:', value: widget.patientName),
                const _InfoRow(label: 'Giới tính:', value: 'Nam'),
                const _InfoRow(label: 'Ngày sinh:', value: '11/12/2000'),
                _InfoRow(label: 'Điện thoại:', value: widget.patientPhone),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: _showDetailDialog,
                child: Text(
                  'Xem chi tiết',
                  style: TextStyle(color: Colors.lightBlue, fontSize: 13),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đặt lịch khám này cho:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Họ và tên:', value: widget.patientName),
                  const _InfoRow(label: 'Giới tính:', value: "Nam"),
                  const _InfoRow(label: 'Ngày sinh:', value: '11/12/2000'),
                  _InfoRow(label: 'Điện thoại:', value: widget.patientPhone),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  VISIT METHOD
class _VisitMethodSection extends StatelessWidget {
  final String examinationMethod;
  final String doctorAddress;
  final String patientAddress;
  final bool hasHomeService;
  final ValueChanged<String> onMethodChanged;

  const _VisitMethodSection({
    required this.examinationMethod,
    required this.doctorAddress,
    required this.patientAddress,
    required this.hasHomeService,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức khám',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => onMethodChanged('at_clinic'),
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color:
                    examinationMethod == 'at_clinic'
                        ? cs.tertiaryContainer
                        : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.secondary),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khám tại phòng khám',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Text('Địa chỉ:', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          doctorAddress,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (hasHomeService && patientAddress != 'Chưa có địa chỉ') ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => onMethodChanged('at_home'),
              child: Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color:
                      examinationMethod == 'at_home'
                          ? cs.tertiaryContainer
                          : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.secondary),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Khám tại nhà',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Địa chỉ:',
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  patientAddress,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right, color: cs.onBackground),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

//  APPOINTMENT DATE
class _AppointmentDateSection extends StatelessWidget {
  final String date;
  final String time;
  final VoidCallback onTap;

  const _AppointmentDateSection({
    required this.date,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ngày khám',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(time.isNotEmpty ? time : '--:--'),
                      const SizedBox(width: 16),
                      Text(date.isNotEmpty ? date : 'Chọn ngày'),
                    ],
                  ),
                  Icon(Icons.keyboard_arrow_right, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  NOTE TO DOCTOR
class _NoteToDoctorSection extends StatelessWidget {
  final TextEditingController controller;

  const _NoteToDoctorSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lời nhắn cho bác sĩ:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Nhập lời nhắn...',
                filled: true,
                fillColor: Colors.grey.shade300,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  FEE SUMMARY
class _FeeSummarySection extends StatelessWidget {
  const _FeeSummarySection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi phí khám tại phòng khám',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Voucher dịch vụ', value: '0đ', valueColor: cs.error),
          const _InfoRow(label: 'Giá dịch vụ', value: '0đ'),
          const _InfoRow(
            label: 'Tạm tính giá tiền',
            value: '0đ',
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}

//  INFO ROW
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight fontWeight;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.onBackground),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              style: TextStyle(
                color: valueColor ?? cs.onBackground,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
