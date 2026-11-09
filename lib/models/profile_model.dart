class ProfileModel {
  final String id;
  final String fullName;
  final String role; // 'citizen' or 'admin'
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Citizen User',
      role: json['role'] as String? ?? 'citizen',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
