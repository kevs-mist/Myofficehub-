class CarModel {
  final String id;
  final String tenantName;
  final String officeNumber;
  final String licensePlateNumber;
  final String parkingNumber;

  CarModel({
    required this.id,
    required this.tenantName,
    required this.officeNumber,
    required this.licensePlateNumber,
    required this.parkingNumber,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as String,
      tenantName: json['tenantName'] as String? ?? 'Tenant',
      officeNumber: json['officeNumber'] as String? ?? 'N/A',
      licensePlateNumber: json['licensePlateNumber'] as String? ?? 'N/A',
      parkingNumber: json['parkingNumber'] as String? ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantName': tenantName,
      'officeNumber': officeNumber,
      'licensePlateNumber': licensePlateNumber,
      'parkingNumber': parkingNumber,
    };
  }
}
