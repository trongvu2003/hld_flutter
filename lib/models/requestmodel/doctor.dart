import 'dart:io';

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