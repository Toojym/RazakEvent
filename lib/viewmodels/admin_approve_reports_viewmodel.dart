import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/report_model.dart';
import '../repositories/report_repository.dart';

class AdminApproveReportsViewModel extends ChangeNotifier {
  final EventModel event;
  final ReportRepository _reportRepo = ReportRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<ReportModel> _reports = [];
  List<ReportModel> get reports => _reports;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  AdminApproveReportsViewModel({required this.event}) {
    _loadReports();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadReports() async {
    _isLoading = true;
    _errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      _reports = await _reportRepo.getReportsForEvent(event.eventId);
    } catch (e) {
      _errorMessage = 'Failed to load reports: $e';
      debugPrint('Error loading reports for event ${event.eventId}: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Updates a report's approval status and refreshes the list.
  Future<void> updateStatus(String reportId, String status) async {
    try {
      await _reportRepo.updateReportStatus(reportId, status);
      // Refresh local list
      final index = _reports.indexWhere((r) => r.reportId == reportId);
      if (index != -1) {
        final old = _reports[index];
        _reports[index] = ReportModel(
          reportId: old.reportId,
          eventId: old.eventId,
          eventName: old.eventName,
          uploaderId: old.uploaderId,
          type: old.type,
          uploadedAt: old.uploadedAt,
          fileUrl: old.fileUrl,
          fileName: old.fileName,
          approvalStatus: status,
        );
        if (!_isDisposed) notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating report status: $e');
      _errorMessage = 'Failed to update status: $e';
      if (!_isDisposed) notifyListeners();
    }
  }
}
