import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/requestmodel/appointment.dart';
import '../../../theme/app_colors.dart';
import '../../../viewmodels/appointment_viewmodel.dart';
import '../../../viewmodels/notification_viewmodel.dart';

class ConfirmBookingScreen extends StatefulWidget {
  const ConfirmBookingScreen({super.key});

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  String _formatDateForServer(String date) {
    if (date.isEmpty) return '';
    final parts = date.split('/');
    if (parts.length != 3) return date;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  Future<void> _handleConfirmBooking(Map<String, dynamic> args) async {
    final appointmentVM = context.read<AppointmentViewModel>();
    final date = args['date']?.toString() ?? '';
    final time = args['time']?.toString() ?? '';
    final examinationMethod = args['examinationMethod']?.toString() ?? '';
    final doctorId = args['doctorId']?.toString() ?? '';
    final patientID = args['patientID']?.toString() ?? '';
    final patientModel = args['patientModel']?.toString() ?? '';
    final reason = args['notes']?.toString() ?? '';
    final totalCost = args['totalCost']?.toString() ?? '0';

    final doctorAddress = args['doctorAddress']?.toString() ?? '';
    final patientAddress = args['patientAddress']?.toString() ?? '';
    final location =
        examinationMethod == 'at_clinic' ? doctorAddress : patientAddress;

    //  Tạo Request Model
    final request = CreateAppointmentRequest(
      doctorID: doctorId,
      patientID: patientID,
      patientModel: patientModel,
      date: _formatDateForServer(date),
      time: time,
      examinationMethod: examinationMethod,
      notes: reason,
      reason: reason,
      totalCost: totalCost,
      location: location,
    );
    final jsonBody = request.toJson();
    print('JSON BODY SENDING: $jsonBody');
    // Lấy token từ nơi bạn lưu trữ ví dụ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken") ?? "";
    print('TOKEN: $token');

    // Gọi API và đợi kết quả
    final result = await appointmentVM.createAppointment(token, request);
    if (!mounted) return;

    //  Xử lý UI dựa trên kết quả
    if (result != null) {
      _showSuccessDialog(args);
    } else {
      _showErrorDialog(appointmentVM.error);
    }
  }


  void _navigateToAppointment(Map<String, dynamic> args) {
    final patientID = args['patientID']?.toString() ?? '';
    final patientModel = args['patientModel']?.toString() ?? 'User';

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main',
          (route) => false,
      arguments: {
        'tabIndex': 1,
        'userId': patientID,
        'userRole': patientModel,
      },
    );
  }

  void _showSuccessDialog(Map<String, dynamic> args) {
    final doctorName = args['doctorName']?.toString() ?? '';
    final patientName = args['patientName']?.toString() ?? '';
    final patientID = args['patientID']?.toString() ?? '';
    final patientModel = args['patientModel']?.toString() ?? '';
    final doctorId = args['doctorId']?.toString() ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Đặt lịch thành công!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _navigateToAppointment(args);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    final notificationVM = context.read<NotificationViewModel>();
    notificationVM.createNotification(
      userId: patientID,
      userModel: patientModel,
      type: "ForAppointment",
      content: "Bạn đã đặt lịch khám thành công với bác sĩ $doctorName",
      navigatePath: "appointment",
    );
    notificationVM.createNotification(
      userId: doctorId,
      userModel: "Doctor",
      type: "ForAppointment",
      content: "Bạn có lịch khám mới với bệnh nhân $patientName",
      navigatePath: "appointment",
    );
  }

  void _showErrorDialog(String errorMsg) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Đặt lịch thất bại"),
            content: Text(errorMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dynamic rawArgs = ModalRoute.of(context)?.settings.arguments;
    final args =
        rawArgs is Map
            ? Map<String, dynamic>.from(rawArgs)
            : <String, dynamic>{};

    final patientName = args['patientName']?.toString() ?? '';
    final doctorName = args['doctorName']?.toString() ?? '';
    final date = args['date']?.toString() ?? '';
    final time = args['time']?.toString() ?? '';
    final reason = args['notes']?.toString() ?? '';
    final totalCost = args['totalCost']?.toString() ?? '0';
    final examinationMethod = args['examinationMethod']?.toString() ?? '';

    final methodText =
        examinationMethod == 'at_clinic'
            ? 'Khám tại phòng khám'
            : 'Khám tại nhà';
    final locationText =
        examinationMethod == 'at_clinic'
            ? (args['doctorAddress']?.toString() ?? '')
            : (args['patientAddress']?.toString() ?? '');

    // Chỉ watch để lấy trạng thái isLoading làm nút xoay tròn
    final appointmentVM = context.watch<AppointmentViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _TopBar(
          title: "Xác nhận lịch hẹn khám",
          onBack: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Xác nhận lại thông tin:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      children: [
                        _InfoText(
                          label: "Họ và tên Bệnh nhân:",
                          value: patientName,
                        ),
                        const SizedBox(height: 24),
                        _InfoText(label: "Bác sĩ đặt khám:", value: doctorName),
                        const SizedBox(height: 24),
                        _InfoText(label: "Ngày đặt khám:", value: date),
                        const SizedBox(height: 24),
                        _InfoText(label: "Giờ đặt khám:", value: time),
                        const SizedBox(height: 24),
                        _InfoText(label: "Lời nhắn cho bác sĩ:", value: reason),
                        const SizedBox(height: 24),
                        _InfoText(
                          label: "Phương thức khám:",
                          value: methodText,
                        ),
                        const SizedBox(height: 24),
                        _InfoText(label: "Địa chỉ khám:", value: locationText),
                        const SizedBox(height: 24),
                        const _InfoText(
                          label: "Mã dịch vụ:",
                          value: "342h59wrt7",
                        ),
                        const SizedBox(height: 24),
                        _InfoText(
                          label: "Tổng phí phải trả:",
                          value: "$totalCost đ",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Text(
                              "Huỷ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            // Chặn bấm nút nếu đang loading
                            onPressed:
                                appointmentVM.isLoading
                                    ? null
                                    : () => _handleConfirmBooking(args),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightTheme,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child:
                                appointmentVM.isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      "Xác nhận",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ],
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

class _InfoText extends StatelessWidget {
  final String label;
  final String value;

  const _InfoText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.clip,
            maxLines: 99,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightTheme,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 24),
                  onPressed: onBack,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
