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
}
