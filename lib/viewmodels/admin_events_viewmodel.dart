import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/report_model.dart';
import '../repositories/event_repository.dart';
import '../repositories/report_repository.dart';

/// ViewModel shared by admin active events and admin past events list pages.
/// Fetches all events and all reports, then partitions events into
/// active (upcoming / currently running) and past (already finished).
class AdminEventsViewModel extends ChangeNotifier {
  final EventRepository _eventRepo = EventRepository();
  final ReportRepository _reportRepo = ReportRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<EventModel> _activeEvents = [];
  List<EventModel> get activeEvents => _activeEvents;

  List<EventModel> _pastEvents = [];
  List<EventModel> get pastEvents => _pastEvents;

  /// Maps eventId → earliest ReportModel for that event.
  /// Used to compute "Uploaded X days early/late" on past events.
  Map<String, ReportModel> _earliestReportByEvent = {};

  bool _isDisposed = false;

  AdminEventsViewModel() {
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

      // Build a map: eventId → earliest report upload date
      final Map<String, ReportModel> reportMap = {};
      for (final report in allReports) {
        if (!reportMap.containsKey(report.eventId) ||
            report.uploadedAt.isBefore(reportMap[report.eventId]!.uploadedAt)) {
          reportMap[report.eventId] = report;
        }
      }
      _earliestReportByEvent = reportMap;

      final now = DateTime.now();
      _activeEvents = [];
      _pastEvents = [];

      for (final event in allEvents) {
        // Use endDate if available, otherwise use start date
        final effectiveEnd = event.endDate ?? event.date;
        if (effectiveEnd.isAfter(now) || effectiveEnd.isAtSameMomentAs(now)) {
          _activeEvents.add(event);
        } else {
          _pastEvents.add(event);
        }
      }

      // Sort active events by date ascending (soonest first)
      _activeEvents.sort((a, b) => a.date.compareTo(b.date));
      // Sort past events by date descending (most recent first)
      _pastEvents.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('AdminEventsViewModel error: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Returns a human-readable string describing how early or late
  /// the paperwork was uploaded relative to the event start date.
  /// Returns null if no report was uploaded for this event.
  String? getPaperworkTimingLabel(EventModel event) {
    final report = _earliestReportByEvent[event.eventId];
    if (report == null) return null;

    final diff = event.date.difference(report.uploadedAt).inDays;
    if (diff > 0) {
      return 'Uploaded $diff day${diff == 1 ? '' : 's'} early';
    } else if (diff < 0) {
      final absDiff = diff.abs();
      return 'Uploaded $absDiff day${absDiff == 1 ? '' : 's'} late';
    } else {
      return 'Uploaded on event day';
    }
  }
}
