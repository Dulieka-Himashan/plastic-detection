class UserModel {
  final String email;
  final String name;
  final String studentId;
  final String faculty;
  final String degree;
  final int totalPoints;
  final String cardUid;
  final String createdAt;

  UserModel({
    required this.email,
    required this.name,
    required this.studentId,
    required this.faculty,
    required this.degree,
    required this.totalPoints,
    required this.cardUid,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      studentId: json['student_id'] ?? '',
      faculty: json['faculty'] ?? '',
      degree: json['degree'] ?? '',
      totalPoints: (json['total_points'] ?? 0).toInt(),
      cardUid: json['card_uid'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'student_id': studentId,
      'faculty': faculty,
      'degree': degree,
      'total_points': totalPoints,
      'card_uid': cardUid,
      'created_at': createdAt,
    };
  }
}