class TenantModel {
  final String id;
  final String name; 
  final String officeNumber;
  final String email;
  final int employeeCount;
  final int vehicleCount;
  final String status; // 'Active', 'Pending'

  TenantModel({
    required this.id,
    required this.name,
    required this.officeNumber,
    required this.email,
    required this.employeeCount,
    required this.vehicleCount,
    required this.status,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      officeNumber: json['officeNumber'] as String,
      email: json['email'] as String,
      employeeCount: (json['employeeCount'] as num).toInt(),
      vehicleCount: (json['vehicleCount'] as num).toInt(),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'officeNumber': officeNumber,
      'email': email,
      'employeeCount': employeeCount,
      'vehicleCount': vehicleCount,
      'status': status,
    };
  }
}
