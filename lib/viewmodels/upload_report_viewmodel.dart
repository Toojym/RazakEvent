import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_model.dart';
import '../models/event_model.dart';
import '../repositories/report_repository.dart';

class UploadReportViewModel extends ChangeNotifier {
  final ReportRepository _reportRepo = ReportRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<bool> uploadReport({
    required EventModel? event,
    required String type,
  }) async {
    if (event == null) {
      _errorMessage = "Please select an event.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final report = ReportModel(
        reportId: '',
        eventId: event.eventId,
        eventName: event.title,
        uploaderId: user.uid,
        type: type,
        uploadedAt: DateTime.now(),
      );

      await _reportRepo.saveReport(report);
      return true;
    } catch (e) {
      _errorMessage = "Failed to upload report: $e";
      return false;
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}
