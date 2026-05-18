import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventRepository {
  final _collection = FirebaseFirestore.instance.collection('events');

  Stream<List<Event>> watchEvents() {
    return _collection
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  Future<void> addEvent(Event event) => _collection.add(event.toMap());
  Future<void> deleteEvent(String id) => _collection.doc(id).delete();
}