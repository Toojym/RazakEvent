import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/report_model.dart';
import '../repositories/event_repository.dart';
import '../repositories/report_repository.dart';

class AdminFilteredReportsViewModel extends ChangeNotifier {
  final String reportType;
  final EventRepository _eventRepo = EventRepository();
  final ReportRepository _reportRepo = ReportRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<ReportWithEvent> _reports = [];
  List<ReportWithEvent> get reports => _reports;

  bool _isDisposed = false;

  AdminFilteredReportsViewModel({required this.reportType}) {
    _load();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _load() async {
    _isLoading = true;
    if (!_isDisposed) notifyListeners();

    try {
      final allReports = await _reportRepo.getAllReportsOnce();
      final filteredReports = allReports.where((r) => r.type == reportType).toList();
      
      // Sort by uploadedAt descending
      filteredReports.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

      // Fetch event details for each report (can optimize later)
      final List<ReportWithEvent> loaded = [];
      for (final report in filteredReports) {
        final event = await _eventRepo.getEvent(report.eventId);
        if (event != null) {
          loaded.add(ReportWithEvent(report: report, event: event));
        }
      }

      _reports = loaded;
    } catch (e) {
      debugPrint('AdminFilteredReportsViewModel error: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}

class ReportWithEvent {
  final ReportModel report;
  final EventModel event;

  ReportWithEvent({required this.report, required this.event});
}
