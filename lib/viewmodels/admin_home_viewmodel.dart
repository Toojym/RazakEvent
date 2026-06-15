import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/date_filter.dart';
import '../repositories/event_repository.dart';
import '../repositories/report_repository.dart';

/// ViewModel for the Admin Home dashboard.
/// Watches all events and reports system-wide (not scoped to a single organizer).
class AdminHomeViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;
  final ReportRepository _reportRepo = ReportRepository();

  StreamSubscription<List<EventModel>>? _eventSub;
  StreamSubscription? _reportSub;

  List<EventModel> _events = [];
  int _uploadedReportsCount = 0;
  bool _isLoading = true;

  AdminHomeViewModel(this._eventRepo) {
    // Watch all upcoming events system-wide
    _eventSub = _eventRepo
        .watchEvents(filter: const DateFilter.upcoming())
        .listen((events) {
          _events = events;
          _isLoading = false;
          notifyListeners();
        }, onError: (error) {
          _isLoading = false;
          notifyListeners();
        });

    // Watch all reports system-wide
    _reportSub = _reportRepo.watchAllReports().listen((reports) {
      _uploadedReportsCount = reports.length;
      notifyListeners();
    }, onError: (error) {
      // Ignore index or permission errors gracefully
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _reportSub?.cancel();
    super.dispose();
  }

  // ── Exposed state ────────────────────────────────────────────────
  bool get isLoading => _isLoading;

  /// Total active (upcoming) events across the entire system.
  int get activeEventsCount => _events.length;

  /// All upcoming events (for navigation to an events list).
  List<EventModel> get allUpcomingEvents => _events;

  /// Total uploaded reports system-wide.
  int get uploadedReportsCount => _uploadedReportsCount;

  /// Total events that have paperwork uploaded.
  int get uploadedPaperworkCount =>
      _events.where((e) => e.hasPaperwork).length;
}
