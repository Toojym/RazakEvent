import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String eventId;
  final String eventName;
  final String uploaderId;
  final String type; // 'Financial' or 'Program'
  final DateTime uploadedAt;

  ReportModel({
    required this.reportId,
    required this.eventId,
    required this.eventName,
    required this.uploaderId,
    required this.type,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() => {
        'eventId': eventId,
        'eventName': eventName,
        'uploaderId': uploaderId,
        'type': type,
        'uploadedAt': Timestamp.fromDate(uploadedAt),
      };

  factory ReportModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ReportModel(
      reportId: documentId,
      eventId: map['eventId'] ?? '',
      eventName: map['eventName'] ?? '',
      uploaderId: map['uploaderId'] ?? '',
      type: map['type'] ?? 'Program',
      uploadedAt: (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
