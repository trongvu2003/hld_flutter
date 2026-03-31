import 'package:hld_flutter/models/responsemodel/service_output.dart';
import 'package:hld_flutter/models/responsemodel/specialty.dart';

class Doctor {
  final String id;
  final String name;
  final Specialty specialty;
  final String address;
  final String avatarURL;
  final bool isClinicPaused;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.address,
    required this.avatarURL,
    required this.isClinicPaused,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      specialty:
      json['specialty'] != null
          ? Specialty.fromJson(json['specialty'])
          : Specialty(id: '', name: ''),
      address: json['address'] ?? '',
      avatarURL: json['avatarURL'] ?? '',
      isClinicPaused: json['isClinicPaused'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'specialty': specialty.toJson(),
      'address': address,
      'avatarURL': avatarURL,
      'isClinicPaused': isClinicPaused,
    };
  }
}


class GetDoctorResponse {
  final String id;
  final String role;
  final String email;
  final String name;
  final List<WorkHour> workingHours;
  final String address;
  final String phone;
  final String password;
  final Specialty specialty;
  final int? experience;
  final String? description;
  final String? avatarURL;
  final String? hospital;
  final String? certificates;
  final List<ServiceOutput> services;
  final int? patientsCount;
  final int? ratingsCount;
  final bool? hasHomeService;
  final bool? isClinicPaused;
  final bool? verified;

  GetDoctorResponse({
    required this.id,
    required this.role,
    required this.email,
    required this.name,
    required this.workingHours,
    required this.address,
    required this.phone,
    required this.password,
    required this.specialty,
    this.experience,
    this.description,
    this.avatarURL,
    this.hospital,
    this.certificates,
    required this.services,
    this.patientsCount,
    this.ratingsCount,
    this.hasHomeService,
    this.isClinicPaused,
    this.verified,
  });

  factory GetDoctorResponse.fromJson(Map<String, dynamic> json) {
    try {
      return GetDoctorResponse(
        id: json['_id']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        workingHours:
            json['workingHours'] != null && json['workingHours'] is List
                ? (json['workingHours'] as List)
                    .map((i) => WorkHour.fromJson(i))
                    .toList()
                : [],

        address: json['address']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        password: json['password']?.toString() ?? '',

        specialty:
            json['specialty'] != null && json['specialty'] is Map
                ? Specialty.fromJson(json['specialty'])
                : Specialty(id: '', name: ''),

        experience: int.tryParse(json['experience']?.toString() ?? ''),
        patientsCount: int.tryParse(json['patientsCount']?.toString() ?? '0'),
        ratingsCount: int.tryParse(json['ratingsCount']?.toString() ?? '0'),
        description: json['description']?.toString(),
        avatarURL: json['avatarURL']?.toString(),
        hospital: json['hospital']?.toString(),
        certificates: json['certificates']?.toString(),
        services:
            json['services'] != null && json['services'] is List
                ? (json['services'] as List)
                    .map((i) => ServiceOutput.fromJson(i))
                    .toList()
                : [],
        hasHomeService: json['hasHomeService'] == true,
        isClinicPaused: json['isClinicPaused'] == true,
        verified: json['verified'] == true,
      );
    } catch (e) {
      // In lỗi ra terminal nếu dòng nào đó bị vỡ để dễ debug
      print('LỖI PARSE JSON TRONG GetDoctorResponse: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'role': role,
      'email': email,
      'name': name,
      'workingHours': workingHours.map((e) => e.toJson()).toList(),
      'address': address,
      'phone': phone,
      'password': password,
      'specialty': specialty.toJson(),
      'experience': experience,
      'description': description,
      'avatarURL': avatarURL,
      'hospital': hospital,
      'certificates': certificates,
      'services': services.map((e) => e.toJson()).toList(),
      'patientsCount': patientsCount,
      'ratingsCount': ratingsCount,
      'hasHomeService': hasHomeService,
      'isClinicPaused': isClinicPaused,
      'verified': verified,
    };
  }
}

class WorkHour {
  final int dayOfWeek;
  final int hour;
  final int minute;

  WorkHour({required this.dayOfWeek, required this.hour, required this.minute});

  factory WorkHour.fromJson(Map<String, dynamic> json) {
    return WorkHour(
      dayOfWeek: json['dayOfWeek'] ?? 0,
      hour: json['hour'] ?? 0,
      minute: json['minute'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'dayOfWeek': dayOfWeek, 'hour': hour, 'minute': minute};
  }
}
