import 'package:hld_flutter/models/responsemodel/doctor.dart';
import 'package:hld_flutter/services/doctor_service.dart';

class DoctorRepository {
  final DoctorService doctorService;

  DoctorRepository(this.doctorService);

  Future<List<GetDoctorResponse>> getDoctors() async{
    return doctorService.getDoctors();
  }

  Future<GetDoctorResponse> getDoctorById(String doctorId) async{
    return doctorService.getDoctorById(doctorId);
  }
}