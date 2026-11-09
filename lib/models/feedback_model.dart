class FeedbackModel {
  final String id;
  final String toiletId;
  final String userId;
  final int overallRating;
  final int cleanlinessRating;
  final int waterRating;
  final int maintenanceRating;
  final int facilitiesRating;
  final String issueCategory;
  final String comments;
  final String? photoPath;
  final Map<String, dynamic>? aiAnalysis;
  final String status; // 'pending', 'in_progress', 'resolved', 'rejected'
  final String? adminResponse;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? toiletName;
  final String? userName;

  FeedbackModel({
    required this.id,
    required this.toiletId,
    required this.userId,
    this.overallRating = 5,
    this.cleanlinessRating = 5,
    this.waterRating = 5,
    this.maintenanceRating = 5,
    this.facilitiesRating = 5,
    required this.issueCategory,
    this.comments = '',
    this.photoPath,
    this.aiAnalysis,
    this.status = 'pending',
    this.adminResponse,
    required this.createdAt,
    this.updatedAt,
    this.toiletName,
    this.userName,
  });

  bool get isResolved => status.toLowerCase() == 'resolved';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isRejected => status.toLowerCase() == 'rejected';

  FeedbackModel copyWith({
    String? id,
    String? toiletId,
    String? userId,
    int? overallRating,
    int? cleanlinessRating,
    int? waterRating,
    int? maintenanceRating,
    int? facilitiesRating,
    String? issueCategory,
    String? comments,
    String? photoPath,
    Map<String, dynamic>? aiAnalysis,
    String? status,
    String? adminResponse,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? toiletName,
    String? userName,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      toiletId: toiletId ?? this.toiletId,
      userId: userId ?? this.userId,
      overallRating: overallRating ?? this.overallRating,
      cleanlinessRating: cleanlinessRating ?? this.cleanlinessRating,
      waterRating: waterRating ?? this.waterRating,
      maintenanceRating: maintenanceRating ?? this.maintenanceRating,
      facilitiesRating: facilitiesRating ?? this.facilitiesRating,
      issueCategory: issueCategory ?? this.issueCategory,
      comments: comments ?? this.comments,
      photoPath: photoPath ?? this.photoPath,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      toiletName: toiletName ?? this.toiletName,
      userName: userName ?? this.userName,
    );
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    // Check if nested toilet or profile joined
    String? tName;
    if (json['toilets'] != null && json['toilets'] is Map) {
      tName = json['toilets']['name'] as String?;
    } else if (json['toilet_name'] != null) {
      tName = json['toilet_name'] as String?;
    }

    String? uName;
    if (json['profiles'] != null && json['profiles'] is Map) {
      uName = json['profiles']['full_name'] as String?;
    } else if (json['user_name'] != null) {
      uName = json['user_name'] as String?;
    }

    return FeedbackModel(
      id: json['id'] as String? ?? '',
      toiletId: json['toilet_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      overallRating: (json['overall_rating'] as num?)?.toInt() ?? 5,
      cleanlinessRating: (json['cleanliness_rating'] as num?)?.toInt() ?? 5,
      waterRating: (json['water_rating'] as num?)?.toInt() ?? 5,
      maintenanceRating: (json['maintenance_rating'] as num?)?.toInt() ?? 5,
      facilitiesRating: (json['facilities_rating'] as num?)?.toInt() ?? 5,
      issueCategory: json['issue_category'] as String? ?? 'General Feedback',
      comments: json['comments'] as String? ?? '',
      photoPath: json['photo_path'] as String?,
      aiAnalysis: json['ai_analysis'] is Map<String, dynamic>
          ? json['ai_analysis'] as Map<String, dynamic>
          : null,
      status: json['status'] as String? ?? 'pending',
      adminResponse: json['admin_response'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      toiletName: tName,
      userName: uName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'toilet_id': toiletId,
      'user_id': userId,
      'overall_rating': overallRating,
      'cleanliness_rating': cleanlinessRating,
      'water_rating': waterRating,
      'maintenance_rating': maintenanceRating,
      'facilities_rating': facilitiesRating,
      'issue_category': issueCategory,
      'comments': comments,
      'photo_path': photoPath,
      'ai_analysis': aiAnalysis,
      'status': status,
      'admin_response': adminResponse,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
