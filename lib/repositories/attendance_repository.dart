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
}
