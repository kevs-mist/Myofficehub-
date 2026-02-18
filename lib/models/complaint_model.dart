class ComplaintModel {
  final String id;
  final String tenantName;
  final String officeNumber;
  final String description;
  final DateTime timestamp;
  final String status; // 'Open', 'Resolved'
  final String type; // 'general', 'personal'

  ComplaintModel({
    required this.id,
    required this.tenantName,
    required this.officeNumber,
    required this.description,
    required this.timestamp,
    required this.status,
    required this.type,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as String,
      tenantName: json['tenantName'] as String,
      officeNumber: json['officeNumber'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      type: (json['type'] as String?) ?? 'personal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantName': tenantName,
      'officeNumber': officeNumber,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'type': type,
    };
  }
}
