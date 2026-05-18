import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final int meritPointsProvided;
  final String clubId;
  final String createdBy;
  final String qrCodeData;
  final String? imageUrl;
  final int? maxCapacity;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.meritPointsProvided,
    required this.clubId,
    required this.createdBy,
    required this.qrCodeData,
    this.imageUrl,
    this.maxCapacity,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'meritPointsProvided': meritPointsProvided,
      'clubId': clubId,
      'createdBy': createdBy,
      'qrCodeData': qrCodeData,
      'imageUrl': imageUrl,
      'maxCapacity': maxCapacity,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map, String documentId) {
    return EventModel(
      eventId: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: map['location'] ?? '',
      meritPointsProvided: map['meritPointsProvided'] ?? 0,
      clubId: map['clubId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      qrCodeData: map['qrCodeData'] ?? '',
      imageUrl: map['imageUrl'],
      maxCapacity: map['maxCapacity'],
    );
  }
}
