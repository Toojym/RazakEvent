import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/registration_model.dart';

class RegistrationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser(String eventId, String userId) async {
    final registrationId = const Uuid().v4();
    final registration = RegistrationModel(
      registrationId: registrationId,
      eventId: eventId,
      userId: userId,
      registeredAt: DateTime.now(),
    );

    await _firestore
        .collection('registrations')
        .doc(registrationId)
        .set(registration.toMap());
  }

  Future<void> unregisterUser(String eventId, String userId) async {
    final query = await _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  }

  Future<bool> hasRegistered(String eventId, String userId) async {
    final query = await _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  Future<List<RegistrationModel>> getRegistrationsForEvent(String eventId) async {
    final query = await _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .get();

    final results = query.docs
        .map((doc) => RegistrationModel.fromMap(doc.data(), doc.id))
        .toList();
    results.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    return results;
  }

  Future<int> getRegistrationCount(String userId) async {
    final query = await _firestore
        .collection('registrations')
        .where('userId', isEqualTo: userId)
        .count()
        .get();
    return query.count ?? 0;
  }
}
