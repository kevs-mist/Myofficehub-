class PaymentModel {
  final String id;
  final String tenantName;
  final String tenantId;
  final double amount;
  final String type; // 'Maintenance', 'Parking'
  final String status; // 'Paid', 'Pending', 'Overdue'
  final DateTime dueDate;

  PaymentModel({
    required this.id,
    required this.tenantName,
    required this.tenantId,
    required this.amount,
    required this.type,
    required this.status,
    required this.dueDate,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      tenantName: json['tenantName'] as String,
      tenantId: json['tenantId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      status: json['status'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantName': tenantName,
      'tenantId': tenantId,
      'amount': amount,
      'type': type,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
    };
  }
}
