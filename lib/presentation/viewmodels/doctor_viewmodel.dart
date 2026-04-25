import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/models/requestmodel/doctor.dart';
import '../../data/models/responsemodel/doctor.dart';
import '../../data/repositories/doctor_repository_impl.dart';


class DoctorViewModel extends ChangeNotifier {
  final DoctorRepository repository;

  DoctorViewModel(this.repository);

  List<GetDoctorResponse> doctors = [];
  GetDoctorResponse? selectedDoctor;
  bool isLoading = false;
  bool isError = false;
  String error = '';

  DoctorAvailableSlotsResponse? doctorSlots;

  Future<void> fetchDoctors() async {
    if (doctors.isNotEmpty) return;
    isLoading = true;
    isError = false;
    notifyListeners();

    try {
      final res = await repository.getDoctors();
      doctors = res;
      print('LẤY BÁC SĨ THÀNH CÔNG: ${doctors.length} người');
    } catch (e) {
      error = e.toString();
      isError = true;
      isLoading = false;
      print('LỖI FETCH DOCTORS: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<GetDoctorResponse?> getDoctorById(String doctorId) async {
    isLoading = true;
    isError = false;
    error = '';
    notifyListeners();

    try {
      selectedDoctor = await repository.getDoctorById(doctorId);
      print('LẤY BÁC SĨ THÀNH CÔNG: ${selectedDoctor?.name}');
      return selectedDoctor;
    } catch (e) {
      isError = true;
      error = e.toString();
      print('LỖI getDoctorById: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<DoctorAvailableSlotsResponse?> fetchAvailableSlots(
    String doctorId,
  ) async {
    isLoading = true;
    isError = false;
    error = '';
    notifyListeners();

    try {
      final res = await repository.getAvailableSlots(doctorId);
      doctorSlots = res;
      return res;
    } catch (e) {
      isError = true;
      error = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _isLoading = false;

  bool get isLoading1 => _isLoading;
  String _applyMessage = "";

  String get applyMessage => _applyMessage;

  void setApplyMessage(String message) {
    _applyMessage = message;
    notifyListeners();
  }

  Future<void> applyForDoctor(
    String userId,
    ApplyDoctorRequest request,
    BuildContext context,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await repository.applyForDoctor(userId, request);
      _handleSuccess(response.message, context);
    } on DioException catch (e) {
      _handleApiError(e, context);
    } catch (e) {
      _applyMessage = "fail";
      _showSnackBar(context, "Lỗi hệ thống: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleSuccess(String message, BuildContext context) {
    final successKeywords = ["thành công", "đã gửi", "trước đó", "hoàn tất"];
    final msgLower = message.toLowerCase();
    _showSnackBar(context, "Đăng ký thành công. Vui lòng chờ xác thực.");
    print("API Success Message: $message");
    if (successKeywords.any((kw) => msgLower.contains(kw))) {
      _applyMessage = "success";
    } else {
      _applyMessage = "fail";
    }
  }

  void _handleApiError(DioException e, BuildContext context) {
    final successKeywords = ["thành công", "đã gửi", "trước đó", "hoàn tất"];
    final errorMsg = (e.response?.data ?? "").toString().toLowerCase();
    print("API Error Body: $errorMsg");

    if (successKeywords.any((kw) => errorMsg.contains(kw))) {
      _applyMessage = "success";
      _showSnackBar(context, "Bạn đã gửi yêu cầu trước đó.");
    } else {
      _applyMessage = "fail";
      _showSnackBar(context, "Đăng ký bác sĩ thất bại.");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  bool? updateSuccess;

  Future<void> updateClinic(
    ModifyClinicRequest request,
    String doctorId,
    BuildContext context,
  ) async {
    isLoading = true;
    updateSuccess = null;
    notifyListeners();
    try {
      final isSuccess = await repository.updateClinicInfo(doctorId, request);
      if (isSuccess) {
        updateSuccess = true;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lưu thông tin phòng khám thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      updateSuccess = false;
      if (context.mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  // Hàm này gọi sau khi chuyển trang thành công để reset lại biến
  void resetUpdateStatus() {
    updateSuccess = null;
    notifyListeners();
  }
}
