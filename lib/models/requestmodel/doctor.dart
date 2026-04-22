import 'dart:io';

import '../responsemodel/doctor.dart';
import '../responsemodel/service_output.dart';

class ApplyDoctorRequest {
  final String license;
  final String specialty;
  final String address;
  final String cccd;
  final File? licenseUrl;
  final File? faceUrl;
  final File? avatarUrl;
  final File? frontCccdUrl;
  final File? backCccdUrl;

  ApplyDoctorRequest({
    required this.license,
    required this.specialty,
    required this.address,
    required this.cccd,
    this.licenseUrl,
    this.faceUrl,
    this.avatarUrl,
    this.frontCccdUrl,
    this.backCccdUrl,
  });
}

class ModifyClinicRequest {
  final List<WorkHour> workingHours;
  final List<WorkHour> oldWorkingHours;
  final String address;
  final String description;
  final List<ServiceInput> services;
  final List<ServiceOutput> oldServices;
  final List<String> images;
  final bool hasHomeService;
  final String specialtyId;
  final bool isClinicPaused;

  ModifyClinicRequest({
    required this.workingHours,
    required this.oldWorkingHours,
    required this.address,
    required this.description,
    required this.services,
    required this.oldServices,
    required this.images,
    required this.hasHomeService,
    required this.specialtyId,
    required this.isClinicPaused,
  });

  Map<String, dynamic> toJson() {
    return {
      'workingHours': workingHours.map((e) => e.toJson()).toList(),
      'oldWorkingHours': oldWorkingHours.map((e) => e.toJson()).toList(),
      'address': address,
      'description': description,
      'services': services.map((e) => e.toJson()).toList(),
      'oldServices': oldServices.map((e) => e.toJson()).toList(),
      'images': images,
      'hasHomeService': hasHomeService,
      'specialtyId': specialtyId,
      'isClinicPaused': isClinicPaused,
    };
  }
}
