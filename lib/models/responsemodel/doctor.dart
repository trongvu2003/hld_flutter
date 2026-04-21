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

class DoctorAvailableSlotsResponse {
  final String doctorID;
  final String doctorName;
  final SearchPeriod searchPeriod;
  final List<AvailableSlot> availableSlots;
  final int totalAvailableDays;
  final int totalAvailableSlots;

  DoctorAvailableSlotsResponse({
    required this.doctorID,
    required this.doctorName,
    required this.searchPeriod,
    required this.availableSlots,
    required this.totalAvailableDays,
    required this.totalAvailableSlots,
  });

  factory DoctorAvailableSlotsResponse.fromJson(Map<String, dynamic> json) {
    return DoctorAvailableSlotsResponse(
      doctorID: json['doctorID'] ?? '',
      doctorName: json['doctorName'] ?? '',
      searchPeriod: SearchPeriod.fromJson(json['searchPeriod'] ?? {}),
      availableSlots:
          (json['availableSlots'] as List? ?? [])
              .map((e) => AvailableSlot.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
      totalAvailableDays: json['totalAvailableDays'] ?? 0,
      totalAvailableSlots: json['totalAvailableSlots'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'doctorID': doctorID,
    'doctorName': doctorName,
    'searchPeriod': searchPeriod.toJson(),
    'availableSlots': availableSlots.map((e) => e.toJson()).toList(),
    'totalAvailableDays': totalAvailableDays,
    'totalAvailableSlots': totalAvailableSlots,
  };
}

class SearchPeriod {
  final String from;
  final String to;
  final int numberOfDays;

  SearchPeriod({
    required this.from,
    required this.to,
    required this.numberOfDays,
  });

  factory SearchPeriod.fromJson(Map<String, dynamic> json) {
    return SearchPeriod(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      numberOfDays: json['numberOfDays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'from': from,
    'to': to,
    'numberOfDays': numberOfDays,
  };
}

class AvailableSlot {
  final String date;
  final int dayOfWeek;
  final String dayName;
  final String displayDate;
  final List<TimeSlot> slots;
  final int totalSlots;

  AvailableSlot({
    required this.date,
    required this.dayOfWeek,
    required this.dayName,
    required this.displayDate,
    required this.slots,
    required this.totalSlots,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      date: json['date'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? 0,
      dayName: json['dayName'] ?? '',
      displayDate: json['displayDate'] ?? '',
      slots:
          (json['slots'] as List? ?? [])
              .map((e) => TimeSlot.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
      totalSlots: json['totalSlots'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'dayOfWeek': dayOfWeek,
    'dayName': dayName,
    'displayDate': displayDate,
    'slots': slots.map((e) => e.toJson()).toList(),
    'totalSlots': totalSlots,
  };

  DateTime? toDateTime() {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }
}

class TimeSlot {
  final String workingHourId;
  final String time;
  final int hour;
  final int minute;
  final String displayTime;

  TimeSlot({
    required this.workingHourId,
    required this.time,
    required this.hour,
    required this.minute,
    required this.displayTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      workingHourId: json['workingHourId'] ?? '',
      time: json['time'] ?? '',
      hour: json['hour'] ?? 0,
      minute: json['minute'] ?? 0,
      displayTime: json['displayTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'workingHourId': workingHourId,
    'time': time,
    'hour': hour,
    'minute': minute,
    'displayTime': displayTime,
  };

  DateTime? toDateTime() {
    try {
      return DateTime(0, 1, 1, hour, minute);
    } catch (e) {
      return null;
    }
  }
}


class ApplyDoctorResponse {
  final String message;

  ApplyDoctorResponse({required this.message});

  factory ApplyDoctorResponse.fromJson(Map<String, dynamic> json) {
    return ApplyDoctorResponse(
      message: json['message']?.toString() ?? '',
    );
  }
}
