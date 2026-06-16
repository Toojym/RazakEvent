import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveReport(ReportModel report) async {
    final docRef = report.reportId.isEmpty
        ? _firestore.collection('reports').doc()
        : _firestore.collection('reports').doc(report.reportId);

    await docRef.set(report.toMap());
  }

  Future<List<ReportModel>> getReportsForOrganizer(String organizerId) async {
    final query = await _firestore
        .collection('reports')
        .where('uploaderId', isEqualTo: organizerId)
        .orderBy('uploadedAt', descending: true)
        .get();

    return query.docs
        .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<ReportModel>> watchReportsForOrganizer(String organizerId) {
    return _firestore
        .collection('reports')
        .where('uploaderId', isEqualTo: organizerId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Streams all reports system-wide (used by admin dashboard).
  Stream<List<ReportModel>> watchAllReports() {
    return _firestore
        .collection('reports')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
            .toList());
  }
  /// Fetches all reports system-wide as a one-shot future (used by admin events).
  Future<List<ReportModel>> getAllReportsOnce() async {
    final snapshot = await _firestore
        .collection('reports')
        .orderBy('uploadedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
