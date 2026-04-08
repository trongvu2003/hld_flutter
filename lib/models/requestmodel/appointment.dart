class CreateAppointmentRequest {
  final String doctorID;
  final String patientID;
  final String patientModel;
  final String date;
  final String time;
  final String examinationMethod;
  final String notes;
  final String reason;
  final String totalCost;
  final String location;

  CreateAppointmentRequest({
    required this.doctorID,
    required this.patientID,
    required this.patientModel,
    required this.date,
    required this.time,
    required this.examinationMethod,
    required this.notes,
    required this.reason,
    required this.totalCost,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      "doctorID": doctorID,
      "patientID": patientID,
      "patientModel": patientModel,
      "date": date,
      "time": time,
      "examinationMethod": examinationMethod,
      "notes": notes,
      "reason": reason,
      "totalCost": totalCost.toString(),
      "location": location,
    };
  }
}