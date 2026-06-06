import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationModel {
  final String registrationId;
  final String eventId;
  final String userId;
  final DateTime registeredAt;

  RegistrationModel({
    required this.registrationId,
    required this.eventId,
    required this.userId,
    required this.registeredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'registeredAt': Timestamp.fromDate(registeredAt),
    };
  }

  factory RegistrationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return RegistrationModel(
      registrationId: documentId,
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      registeredAt: (map['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
