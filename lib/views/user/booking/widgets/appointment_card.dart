import 'package:flutter/material.dart';
import '../../../../models/responsemodel/appointment.dart';
import '../../../../theme/app_colors.dart';

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
                errorBuilder:
                    (_, __, ___) => ClipOval(
                      child: Image.asset(
                        'assets/images/avatar_doctor.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
              )
              : ClipOval(
                child: Image.asset(
                  'assets/images/avatar_doctor.jpg',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
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
                backgroundColor: AppColors.lightTheme,
                shape: RoundedCornerShape(8),
              ),
              child: const Text(
                'Đánh giá',
                style: TextStyle(color: Colors.black),
              ),
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

// Bo góc dùng như RoundedCornerShape
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
