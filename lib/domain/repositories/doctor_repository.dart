import '../../data/models/requestmodel/doctor.dart';
import '../../data/models/responsemodel/doctor.dart';

abstract class DoctorRepository {
  Future<List<GetDoctorResponse>> getDoctors();

  Future<GetDoctorResponse> getDoctorById(String doctorId);

  Future<DoctorAvailableSlotsResponse> getAvailableSlots(String doctorId);

  Future<ApplyDoctorResponse> applyForDoctor(
      String userId,
      ApplyDoctorRequest request,
      );

  Future<bool> updateClinicInfo(
      String doctorId,
      ModifyClinicRequest request,
      );
}