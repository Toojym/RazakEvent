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

  Future<void> addEvent(EventModel event) => _collection.add(event.toMap());
  Future<void> deleteEvent(String id) => _collection.doc(id).delete();
}