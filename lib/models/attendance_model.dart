import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String attendanceId;
  final String eventId;
  final String userId;
  final DateTime scannedAt;
  final int pointsAwarded;

  AttendanceModel({
    required this.attendanceId,
    required this.eventId,
    required this.userId,
    required this.scannedAt,
    required this.pointsAwarded,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'scannedAt': Timestamp.fromDate(scannedAt),
      'pointsAwarded': pointsAwarded,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AttendanceModel(
      attendanceId: documentId,
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      scannedAt: (map['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pointsAwarded: map['pointsAwarded'] ?? 0,
    );
  }
}
