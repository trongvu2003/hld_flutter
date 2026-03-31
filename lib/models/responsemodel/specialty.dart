import 'doctor.dart';

class GetSpecialtyResponse {
  final String id;
  final String name;
  final String icon;
  final List<Doctor> doctors;
  final String description;

  GetSpecialtyResponse({
    required this.id,
    required this.name,
    required this.icon,
    required this.doctors,
    required this.description,
  });

  factory GetSpecialtyResponse.fromJson(Map<String, dynamic> json) {
    return GetSpecialtyResponse(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      // Xử lý parse một mảng JSON thành List<Doctor>
      doctors:
          json['doctors'] != null
              ? (json['doctors'] as List).map((e) => Doctor.fromJson(e)).toList()
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
      'doctors': doctors.map((e) => e.toJson()).toList(),
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
