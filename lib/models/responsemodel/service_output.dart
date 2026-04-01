class ServiceOutput {
  final String specialtyId;
  final String specialtyName;
  final String description;
  final List<String> imageService;
  final int minprice;
  final int maxprice;

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
      imageService: json['imageService'] is List
          ? List<String>.from(json['imageService'])
          : [],
      minprice: json['minprice'] is int
          ? json['minprice']
          : int.tryParse(json['minprice']?.toString() ?? '') ?? 0,
      maxprice: json['maxprice'] is int
          ? json['maxprice']
          : int.tryParse(json['maxprice']?.toString() ?? '') ?? 0,
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
