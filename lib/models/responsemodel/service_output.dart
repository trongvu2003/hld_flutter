class ServiceOutput {
  final String specialtyId;
  final String specialtyName;
  final String description;
  final List<String> imageService;
  final String minprice;
  final String maxprice;

  ServiceOutput({
    required this.specialtyId,
    required this.specialtyName,
    required this.description,
    required this.imageService,
    required this.minprice,
    required this.maxprice,
  });

  factory ServiceOutput.fromJson(Map<String, dynamic> json) {
    return ServiceOutput(
      specialtyId: json['specialtyId']?.toString() ?? '',
      specialtyName: json['specialtyName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageService:
          json['imageService'] != null && json['imageService'] is List
              ? List<String>.from(json['imageService'])
              : [],
      minprice: json['minprice']?.toString() ?? '',
      maxprice: json['maxprice']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialtyId': specialtyId,
      'specialtyName': specialtyName,
      'description': description,
      'imageService': imageService,
      'minprice': minprice,
      'maxprice': maxprice,
    };
  }
}
