class AppointmentResponse {
  final String id;
  final Doctor doctor;
  final String patientModel;
  final Patient patient;
  final String date;
  final String time;
  final String status;
  final String examinationMethod;
  final String notes;
  final String location;
  final String createdAt;
  final String updatedAt;
  final String note;

  AppointmentResponse({
    required this.id,
    required this.doctor,
    required this.patientModel,
    required this.patient,
    required this.date,
    required this.time,
    required this.status,
    required this.examinationMethod,
    required this.notes,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.note,
  });

  factory AppointmentResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentResponse(
      id: json['_id'] ?? '',
      doctor: Doctor.fromJson(json['doctor'] ?? {}),
      patientModel: json['patientModel'] ?? '',
      patient: Patient.fromJson(json['patient'] ?? {}),
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
      examinationMethod: json['examinationMethod'] ?? '',
      notes: json['notes'] ?? '',
      location: json['location'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'doctor': doctor.toJson(),
      'patientModel': patientModel,
      'patient': patient.toJson(),
      'date': date,
      'time': time,
      'status': status,
      'examinationMethod': examinationMethod,
      'notes': notes,
      'location': location,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'note': note,
    };
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String avatarURL;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarURL,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      avatarURL: json['avatarURL'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'specialty': specialty,
      'avatarURL': avatarURL,
    };
  }
}

class Patient {
  final String id;
  final String name;
  final String avatarURL;

  Patient({required this.id, required this.name, required this.avatarURL});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      avatarURL: json['avatarURL'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'avatarURL': avatarURL};
  }
}


class CreateAppointmentResponse {
  final String message;
  final Appointment appointment;

  CreateAppointmentResponse({
    required this.message,
    required this.appointment,
  });

  factory CreateAppointmentResponse.fromJson(Map<String, dynamic> json) {
    return CreateAppointmentResponse(
      message: json['message'] ?? '',
      appointment: Appointment.fromJson(json['appointment'] ?? {}),
    );
  }
}

class Appointment {
  final String id;
  final String doctor;
  final String patient;
  final String date;
  final String time;
  final String status;
  final String examinationMethod;
  final String reason;
  final String? notes;
  final double totalCost;

  Appointment({
    required this.id,
    required this.doctor,
    required this.patient,
    required this.date,
    required this.time,
    required this.status,
    required this.examinationMethod,
    required this.reason,
    this.notes,
    required this.totalCost,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      doctor: json['doctor'] ?? '',
      patient: json['patient'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
      examinationMethod: json['examinationMethod'] ?? '',
      reason: json['reason'] ?? '',
      notes: json['notes'],
      totalCost: double.tryParse(json['totalCost']?.toString() ?? '0') ?? 0.0,
    );
  }
}