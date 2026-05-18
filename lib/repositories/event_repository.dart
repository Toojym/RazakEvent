import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createEvent(EventModel event) async {
    await _firestore.collection('events').doc(event.eventId).set(event.toMap());
  }

  Future<List<EventModel>> getUpcomingEvents() async {
    final snapshot = await _firestore
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('date')
        .get();

    return snapshot.docs
        .map((doc) => EventModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
