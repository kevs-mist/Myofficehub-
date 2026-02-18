class TenantProfileModel {
  final String companyName;
  final String accountHolderName;
  final String unitOrOffice;
  final String carLicensePlateNumber;
  final String parkingNumber;

  TenantProfileModel({
    required this.companyName,
    required this.accountHolderName,
    required this.unitOrOffice,
    required this.carLicensePlateNumber,
    required this.parkingNumber,
  });

  factory TenantProfileModel.fromJson(Map<String, dynamic> json) {
    return TenantProfileModel(
      companyName: json['companyName'] as String? ?? 'My Workspace',
      accountHolderName: json['accountHolderName'] as String? ?? 'Tenant',
      unitOrOffice: json['unitOrOffice'] as String? ?? 'N/A',
      carLicensePlateNumber:
          json['carLicensePlateNumber'] as String? ?? 'N/A',
      parkingNumber: json['parkingNumber'] as String? ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'accountHolderName': accountHolderName,
      'unitOrOffice': unitOrOffice,
      'carLicensePlateNumber': carLicensePlateNumber,
      'parkingNumber': parkingNumber,
    };
  }
}
