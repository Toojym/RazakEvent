import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> recordAttendance(AttendanceModel attendance) async {
    await _firestore
        .collection('attendances')
        .doc(attendance.attendanceId)
        .set(attendance.toMap());
  }

  /// Checks if the user has already recorded attendance for this event.
  Future<bool> hasDuplicateAttendance({
    required String eventId,
    required String userId,
  }) async {
    final query = await _firestore
        .collection('attendances')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
        
    return query.docs.isNotEmpty;
  }

  /// Gets the total number of events the user has attended.
  Future<int> getParticipatedCount(String userId) async {
    final query = await _firestore
        .collection('attendances')
        .where('userId', isEqualTo: userId)
        .where('joinRole', isEqualTo: 'attendee')
        .count()
        .get();
    return query.count ?? 0;
  }

  /// Gets the total number of events the user has volunteered for.
  Future<int> getVolunteeredCount(String userId) async {
    final query = await _firestore
        .collection('attendances')
        .where('userId', isEqualTo: userId)
        .where('joinRole', isEqualTo: 'crew')
        .count()
        .get();
    return query.count ?? 0;
  }

  /// Gets all attendees for a specific event
  Future<List<AttendanceModel>> getAttendeesForEvent(String eventId) async {
    final query = await _firestore
        .collection('attendances')
        .where('eventId', isEqualTo: eventId)
        .get();

    final docs = query.docs
        .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
        .toList();
    
    docs.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return docs;
  }
}
