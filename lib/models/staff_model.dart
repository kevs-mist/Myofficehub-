class StaffModel {
  final String id;
  final String name;
  final String role; // 'security' | 'help'
  final String photoUrl;
  final List<String> assignedOffices;

  StaffModel({
    required this.id,
    required this.name,
    required this.role,
    required this.photoUrl,
    required this.assignedOffices,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Staff',
      role: json['role'] as String? ?? 'security',
      photoUrl: json['photoUrl'] as String? ?? '',
      assignedOffices: (json['assignedOffices'] as List?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'assignedOffices': assignedOffices,
    };
  }
}
