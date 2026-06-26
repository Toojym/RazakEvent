import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/date_filter.dart';

class EventRepository {
  final _collection = FirebaseFirestore.instance.collection('events');

  Stream<List<EventModel>> watchEvents({DateFilter? filter}) {
    Query<Map<String, dynamic>> query = _collection.orderBy('date', descending: false);

    if (filter != null) {
      if (filter.upcomingOnly) {
        final startOfToday = DateTime.now();
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday),
        );
      } else if (filter.from != null && filter.to != null) {
        final endOfTo = DateTime(
          filter.to!.year,
          filter.to!.month,
          filter.to!.day,
          23, 59, 59,
        );
        query = query
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(filter.from!))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfTo));
      }
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => EventModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addEvent(EventModel event) => _collection.doc(event.eventId).set(event.toMap());
  Future<void> updateEvent(EventModel event) => _collection.doc(event.eventId).update(event.toMap());
  Future<void> deleteEvent(String id) => _collection.doc(id).delete();

  /// Looks up an event matching the scanned QR code.
  /// Checks both attendee and crew QR code fields.
  Future<EventModel?> findByQrCodeData(String qrData) async {
    // Check if it matches an attendee QR code
    final attendeeQuery = await _collection
        .where('attendeeQrCodeData', isEqualTo: qrData)
        .limit(1)
        .get();

    if (attendeeQuery.docs.isNotEmpty) {
      final doc = attendeeQuery.docs.first;
      return EventModel.fromMap(doc.data(), doc.id);
    }

    // Check if it matches a crew QR code
    final crewQuery = await _collection
        .where('crewQrCodeData', isEqualTo: qrData)
        .limit(1)
        .get();

    if (crewQuery.docs.isNotEmpty) {
      final doc = crewQuery.docs.first;
      return EventModel.fromMap(doc.data(), doc.id);
    }

    return null;
  }

  Future<EventModel?> getEvent(String eventId) async {
    final doc = await _collection.doc(eventId).get();
    if (doc.exists) {
      return EventModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<EventModel>> getEventsByOrganizer(String organizerId) async {
    final query = await _collection.where('createdBy', isEqualTo: organizerId).get();
    return query.docs.map((doc) => EventModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<EventModel>> getAllEvents() async {
    final query = await _collection.get();
    return query.docs.map((doc) => EventModel.fromMap(doc.data(), doc.id)).toList();
  }
}