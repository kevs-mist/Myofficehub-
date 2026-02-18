class AdminModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String officeComplexName;
  final double maintenanceFee;
  final double parkingFee;
  final double lateFee;
  final String upiId;
  final String whatsappGroupNumber;

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.officeComplexName,
    required this.maintenanceFee,
    required this.parkingFee,
    required this.lateFee,
    required this.upiId,
    required this.whatsappGroupNumber,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      officeComplexName: json['officeComplexName'] as String,
      maintenanceFee: (json['maintenanceFee'] as num).toDouble(),
      parkingFee: (json['parkingFee'] as num).toDouble(),
      lateFee: (json['lateFee'] as num?)?.toDouble() ?? 0,
      upiId: json['upiId'] as String,
      whatsappGroupNumber: json['whatsappGroupNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'officeComplexName': officeComplexName,
      'maintenanceFee': maintenanceFee,
      'parkingFee': parkingFee,
      'lateFee': lateFee,
      'upiId': upiId,
      'whatsappGroupNumber': whatsappGroupNumber,
    };
  }
}
