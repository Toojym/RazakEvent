class UserModel {
  final String uid;
  final String name;
  final String matric;
  final String kolej;
  final String faculty;
  final int meritPoints;
  final String role;
  final String email; // stored for matric-based login lookup

  UserModel({
    required this.uid,
    required this.name,
    required this.matric,
    required this.kolej,
    this.faculty = 'Faculty of Computing',
    required this.meritPoints,
    required this.role,
    required this.email,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'matric': matric,
    'kolej': kolej,
    'faculty': faculty,
    'meritPoints': meritPoints,
    'role': role,
    'email': email,
  };

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      matric: map['matric'] ?? '',
      kolej: map['kolej'] ?? '',
      faculty: map['faculty'] ?? 'Faculty of Computing',
      meritPoints: map['meritPoints'] ?? 0,
      role: map['role'] ?? 'student',
      email: map['email'] ?? '',
    );
  }

  bool get isOrganizer => role == 'organizer';
  bool get isStudent => role == 'student';
}
