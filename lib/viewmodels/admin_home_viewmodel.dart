import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

/// ViewModel for the Admin Home dashboard.
/// Watches all events system-wide.
class AdminHomeViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;

  StreamSubscription<List<EventModel>>? _eventSub;

  List<EventModel> _events = [];
  bool _isLoading = true;

  AdminHomeViewModel(this._eventRepo) {
    // Watch all events system-wide
    _eventSub = _eventRepo
        .watchEvents()
        .listen((events) {
          _events = events;
          _isLoading = false;
          notifyListeners();
        }, onError: (error) {
          _isLoading = false;
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  // ── Exposed state ────────────────────────────────────────────────
  bool get isLoading => _isLoading;

  /// Total active (upcoming) events across the entire system.
  int get activeEventsCount {
    final now = DateTime.now().subtract(const Duration(hours: 1));
    return _events.where((e) => e.date.isAfter(now)).length;
  }

  /// All upcoming events (for navigation to an events list).
  List<EventModel> get allUpcomingEvents {
    final now = DateTime.now().subtract(const Duration(hours: 1));
    return _events.where((e) => e.date.isAfter(now)).toList();
  }

  /// Total events that have paperwork uploaded.
  int get uploadedPaperworkCount =>
      _events.where((e) => e.hasPaperwork).length;
}

