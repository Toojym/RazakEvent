import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String clubId;
  final String createdBy;
  final DateTime date;
  final String description;
  final String imageUrl;
  final String location;
  final String maxCapacity;
  final int meritPointsProvided;
  final String qrCodeData;
  final String title;

  Event({
    required this.id,
    required this.clubId,
    required this.createdBy,
    required this.date,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.maxCapacity,
    required this.meritPointsProvided,
    required this.qrCodeData,
    required this.title,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      clubId: data['clubId'] ?? '',
      createdBy: data['createdBy'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      location: data['location'] ?? '',
      maxCapacity: data['maxCapacity'] ?? '',
      meritPointsProvided: data['meritPointsProvided'] ?? 0,
      qrCodeData: data['qrCodeData'] ?? '',
      title: data['title'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'clubId': clubId,
    'createdBy': createdBy,
    'date': Timestamp.fromDate(date),
    'description': description,
    'imageUrl': imageUrl,
    'location': location,
    'maxCapacity': maxCapacity,
    'meritPointsProvided': meritPointsProvided,
    'qrCodeData': qrCodeData,
    'title': title,
  };
}