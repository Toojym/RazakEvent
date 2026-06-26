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
  final DateTime? endDate;
  final String location;
  final int attendeeMeritPoints;
  final int crewMeritPoints;
  final String createdBy;
  final String attendeeQrCodeData;
  final String crewQrCodeData;

  final String? posterUrl;
  final bool hasPaperwork;
  final int? maxCapacity;
  final String category; // Sports | Academic | Arts | Cultural | Other
  final double fee;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    this.endDate,
    required this.location,
    required this.attendeeMeritPoints,
    required this.crewMeritPoints,
    required this.createdBy,
    required this.attendeeQrCodeData,
    required this.crewQrCodeData,

    this.posterUrl,
    this.hasPaperwork = false,
    this.maxCapacity,
    this.category = 'Other',
    this.fee = 0.0,
  });

  String? get displayImageUrl => posterUrl;

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'date': Timestamp.fromDate(date),
    'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    'location': location,
    'attendeeMeritPoints': attendeeMeritPoints,
    'crewMeritPoints': crewMeritPoints,
    'createdBy': createdBy,
    'attendeeQrCodeData': attendeeQrCodeData,
    'crewQrCodeData': crewQrCodeData,

    'posterUrl': posterUrl,
    'hasPaperwork': hasPaperwork,
    'maxCapacity': maxCapacity,
    'category': category,
    'fee': fee,
  };

  static String? _cleanUrl(dynamic url) {
    if (url == null) return null;
    final str = url.toString().trim();
    if (str.isEmpty) return null;
    return str;
  }

  static double _parseFee(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  factory EventModel.fromMap(Map<String, dynamic> map, String documentId) {
    return EventModel(
      eventId: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      location: map['location'] ?? '',
      attendeeMeritPoints: map['attendeeMeritPoints'] ?? 1,
      crewMeritPoints: map['crewMeritPoints'] ?? 3,
      createdBy: map['createdBy'] ?? '',
      attendeeQrCodeData: map['attendeeQrCodeData'] ?? '',
      crewQrCodeData: map['crewQrCodeData'] ?? '',

      posterUrl: _cleanUrl(map['posterUrl']),
      hasPaperwork: map['hasPaperwork'] ?? false,
      maxCapacity: map['maxCapacity'],
      category: map['category'] ?? 'Other',
      fee: _parseFee(map['fee'] ?? map['registrationFee']),
    );
  }
}
