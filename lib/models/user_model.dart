class UserModel {
  final String name;
  final String matric;
  final String kolej;
  final int meritPoints;

  UserModel({
    required this.name,
    required this.matric,
    required this.kolej,
    required this.meritPoints,
  });

  // Convert Dart object → Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'matric': matric,
      'kolej': kolej,
      'meritPoints': meritPoints,
    };
  }

  // Convert Firestore → Dart object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      matric: map['matric'] ?? '',
      kolej: map['kolej'] ?? '',
      meritPoints: map['meritPoints'] ?? 0,
    );
  }
}