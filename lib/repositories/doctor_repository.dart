import 'package:hld_flutter/models/responsemodel/doctor.dart';
import 'package:hld_flutter/services/doctor_service.dart';

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
}
