class GetSpecialtyResponse {
  final String id;
  final String name;
  final String icon;
  final List<Doctor> doctor;
  final String description;

  GetSpecialtyResponse({
    required this.id,
    required this.name,
    required this.icon,
    required this.doctor,
    required this.description,
  });

  factory GetSpecialtyResponse.fromJson(Map<String, dynamic> json) {
    return GetSpecialtyResponse(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      // Xử lý parse một mảng JSON thành List<Doctor>
      doctor:
          json['doctor'] != null
              ? (json['doctor'] as List).map((e) => Doctor.fromJson(e)).toList()
              : [],
    );
  }

  // Thêm hàm toJson (Best practice khi làm việc với model)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'doctor': doctor.map((e) => e.toJson()).toList(),
    };
  }
}

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

class Specialty {
  final String id;
  final String name;

  Specialty({required this.id, required this.name});

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}
