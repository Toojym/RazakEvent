class UserModel {
  final String uid;
  final String name;
  final String matric;
  final String kolej;
  final int meritPoints;
  final String role;
  final String? clubId;

  UserModel({
    required this.uid,
    required this.name,
    required this.matric,
    required this.kolej,
    required this.meritPoints,
    required this.role,
    this.clubId,
  });

  // Convert Dart object → Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'matric': matric,
      'kolej': kolej,
      'meritPoints': meritPoints,
      'role': role,
      'clubId': clubId,
    };
  }

  // Convert Firestore → Dart object
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      matric: map['matric'] ?? '',
      kolej: map['kolej'] ?? '',
      meritPoints: map['meritPoints'] ?? 0,
      role: map['role'] ?? 'student',
      clubId: map['clubId'],
    );
  }
}