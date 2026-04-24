import 'dart:io';
import 'package:dio/dio.dart';
import '../datasources/services/doctor_service.dart';
import '../models/requestmodel/doctor.dart';
import '../models/responsemodel/doctor.dart';

class DoctorRepository {
  final DoctorService doctorService;

  DoctorRepository(this.doctorService);

  Future<List<GetDoctorResponse>> getDoctors() async {
    return await doctorService.getDoctors();
  }

  Future<GetDoctorResponse> getDoctorById(String doctorId) async {
    return await doctorService.getDoctorById(doctorId);
  }

  Future<DoctorAvailableSlotsResponse> getAvailableSlots(
    String doctorId,
  ) async {
    return await doctorService.getAvailableSlots(doctorId);
  }

  Future<ApplyDoctorResponse> applyForDoctor(
    String userId,
    ApplyDoctorRequest request,
  ) async {
    // Map các trường văn bản
    Map<String, dynamic> formDataMap = {
      "license": request.license,
      "specialty": request.specialty,
      "CCCD": request.cccd,
      "address": request.address,
    };

    FormData formData = FormData.fromMap(formDataMap);
    // Hàm helper đọc file ảnh thành MultipartFile
    Future<void> addFile(String key, File? file) async {
      if (file != null) {
        String fileName = file.path.split('/').last;
        formData.files.add(
          MapEntry(
            key,
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      }
    }

    //  Nhét file vào form
    await addFile("licenseUrl", request.licenseUrl);
    await addFile("faceUrl", request.faceUrl);
    await addFile("avatarURL", request.avatarUrl);
    await addFile("frontCccdUrl", request.frontCccdUrl);
    await addFile("backCccdUrl", request.backCccdUrl);

    final response = await doctorService.applyForDoctor(userId, formData);
    return ApplyDoctorResponse.fromJson(response.data);
  }

  Future<bool> updateClinicInfo(
    String doctorId,
    ModifyClinicRequest request,
  ) async {
    try {
      return await doctorService.updateClinicInfo(doctorId, request);
    } catch (e) {
      rethrow;
    }
  }
}
