import 'package:cloud_firestore/cloud_firestore.dart';

// Available event categories — update this list to match your Firestore data.
// If you add a new category in Firestore, add it here too.
class EventCategories {
  static const String sports = 'Sports';
  static const String academic = 'Academic';
  static const String arts = 'Arts';
  static const String cultural = 'Cultural';
  static const String other = 'Other';

  static const List<String> all = [sports, academic, arts, cultural, other];
}

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
  final String? posterUrl;
  final String? headerUrl;
  final bool hasPaperwork;
  final int? maxCapacity;
  final String category; // Sports | Academic | Arts | Cultural | Other

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
    this.posterUrl,
    this.headerUrl,
    this.hasPaperwork = false,
    this.maxCapacity,
    this.category = 'Other',
  });

  Map<String, dynamic> toMap() => {
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
    'posterUrl': posterUrl,
    'headerUrl': headerUrl,
    'hasPaperwork': hasPaperwork,
    'maxCapacity': maxCapacity,
    'category': category,
  };

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
      posterUrl: map['posterUrl'],
      headerUrl: map['headerUrl'],
      hasPaperwork: map['hasPaperwork'] ?? false,
      maxCapacity: map['maxCapacity'],
      category: map['category'] ?? 'Other',
    );
  }
}
