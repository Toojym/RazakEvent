import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final int attendeeMeritPoints;
  final int crewMeritPoints;
  final String createdBy;
  final String attendeeQrCodeData;
  final String crewQrCodeData;
  final String? imageUrl;
  final int? maxCapacity;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.attendeeMeritPoints,
    required this.crewMeritPoints,
    required this.createdBy,
    required this.attendeeQrCodeData,
    required this.crewQrCodeData,
    this.imageUrl,
    this.maxCapacity,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'attendeeMeritPoints': attendeeMeritPoints,
      'crewMeritPoints': crewMeritPoints,
      'createdBy': createdBy,
      'attendeeQrCodeData': attendeeQrCodeData,
      'crewQrCodeData': crewQrCodeData,
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
      attendeeMeritPoints: map['attendeeMeritPoints'] ?? 1,
      crewMeritPoints: map['crewMeritPoints'] ?? 3,
      createdBy: map['createdBy'] ?? '',
      attendeeQrCodeData: map['attendeeQrCodeData'] ?? '',
      crewQrCodeData: map['crewQrCodeData'] ?? '',
      imageUrl: map['imageUrl'],
      maxCapacity: map['maxCapacity'],
    );
  }
}
