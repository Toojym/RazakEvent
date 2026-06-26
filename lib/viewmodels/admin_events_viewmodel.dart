import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

/// ViewModel shared by admin active events and admin past events list pages.
/// Fetches all events, then partitions events into
/// active (upcoming / currently running) and past (already finished).
class AdminEventsViewModel extends ChangeNotifier {
  final EventRepository _eventRepo = EventRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<EventModel> _activeEvents = [];
  List<EventModel> get activeEvents => _activeEvents;

  List<EventModel> _pastEvents = [];
  List<EventModel> get pastEvents => _pastEvents;

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

  /// Returns label indicating whether paperwork was attached.
  String? getPaperworkTimingLabel(EventModel event) {
    if (!event.hasPaperwork) return null;
    return 'Paperwork submitted';
  }
}

