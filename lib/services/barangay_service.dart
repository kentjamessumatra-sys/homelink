class BarangayService {
  final String id;
  final String serviceName;
  final String description;
  final String requirements;
  final double fee;
  final bool isActive;

  BarangayService({
    required this.id,
    required this.serviceName,
    required this.description,
    required this.requirements,
    required this.fee,
    required this.isActive,
  });

  factory BarangayService.fromJson(Map<String, dynamic> json) {
    return BarangayService(
      id: json['id'] as String,
      serviceName: json['service_name'] as String,
      description: json['description'] as String,
      requirements: json['requirements'] as String,
      fee: (json['fee'] as num).toDouble(),
      isActive: json['is_active'] as bool,
    );
  }
}