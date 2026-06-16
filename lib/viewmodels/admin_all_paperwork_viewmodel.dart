import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/report_model.dart';
import '../repositories/event_repository.dart';
import '../repositories/report_repository.dart';

/// ViewModel for the admin paperwork list page.
/// Loads all events and their associated reports so the admin
/// can browse paperwork per event.
class AdminAllPaperworkViewModel extends ChangeNotifier {
  final EventRepository _eventRepo = EventRepository();
  final ReportRepository _reportRepo = ReportRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<EventWithReports> _eventsWithReports = [];
  List<EventWithReports> get eventsWithReports => _eventsWithReports;

  bool _isDisposed = false;

  AdminAllPaperworkViewModel() {
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
      final allEvents = await _eventRepo.getAllEvents();
      final allReports = await _reportRepo.getAllReportsOnce();

      // Group reports by eventId
      final Map<String, List<ReportModel>> reportsByEvent = {};
      for (final report in allReports) {
        reportsByEvent.putIfAbsent(report.eventId, () => []).add(report);
      }

      // Build list — only include events that have at least one report
      _eventsWithReports = allEvents
          .where((e) => reportsByEvent.containsKey(e.eventId))
          .map((e) => EventWithReports(
                event: e,
                reports: reportsByEvent[e.eventId]!,
              ))
          .toList()
        ..sort((a, b) => b.event.date.compareTo(a.event.date));
    } catch (e) {
      debugPrint('AdminAllPaperworkViewModel error: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}

class EventWithReports {
  final EventModel event;
  final List<ReportModel> reports;

  EventWithReports({required this.event, required this.reports});

  int get totalReports => reports.length;
  int get approvedCount =>
      reports.where((r) => r.approvalStatus == 'approved').length;
  int get deniedCount =>
      reports.where((r) => r.approvalStatus == 'denied').length;
  int get pendingCount =>
      reports.where((r) => r.approvalStatus == 'pending').length;
}
