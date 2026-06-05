import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Create a new user document in Firestore ──────────────────────
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  // ── Fetch a user profile by UID ──────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // ── Look up a user's email by matric number ──────────────────────
  // Used during login: user types matric → we fetch their email →
  // Firebase Auth signs in with that email.
  //
  // ⚠️  Firestore Security Rule required:
  //   match /users/{uid} {
  //     allow read: if request.auth != null
  //                 || resource.data.keys().hasOnly(['email']);
  //   }
  // Or create a separate public 'matric_index' collection if preferred.
  Future<String?> getEmailByMatric(String matric) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('matric', isEqualTo: matric.trim().toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return query.docs.first.data()['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  // ── Calculate the user's leaderboard rank ──────────────────────────
  Future<int> getUserRank(int userMeritPoints) async {
    try {
      final countQuery = await _firestore
          .collection('users')
          .where('meritPoints', isGreaterThan: userMeritPoints)
          .count()
          .get();
          
      return (countQuery.count ?? 0) + 1;
    } catch (_) {
      return 0; // Return 0 or handle error if needed
    }
  }

  // ── Atomically add merit points to a user's profile ───────────────
  /// Uses [FieldValue.increment] so concurrent scans never overwrite
  /// each other. If the `meritPoints` field doesn't exist yet on the
  /// document, Firestore treats the missing value as 0 and creates it.
  Future<void> addMeritPoints({
    required String uid,
    required int points,
  }) async {
    await _firestore.collection('users').doc(uid).set(
      {'meritPoints': FieldValue.increment(points)},
      SetOptions(merge: true),
    );
  }

  // ── Real-time leaderboard stream ──────────────────────────────────
  /// Returns a live stream of users sorted by [meritPoints] descending.
  /// Any Firestore write (e.g. from [addMeritPoints]) immediately pushes
  /// an updated snapshot through this stream, ensuring instant UI updates.
  Stream<List<UserModel>> watchLeaderboard({int limit = 10}) {
    return _firestore
        .collection('users')
        .orderBy('meritPoints', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
