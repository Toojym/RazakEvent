import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

/// ViewModel for the admin paperwork list page.
/// Loads all events that have uploaded paperwork attached.
class AdminAllPaperworkViewModel extends ChangeNotifier {
  final EventRepository _eventRepo = EventRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<EventModel> _paperworkEvents = [];
  List<EventModel> get paperworkEvents => _paperworkEvents;

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
      _paperworkEvents = allEvents
          .where((e) => e.hasPaperworkAttached)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('AdminAllPaperworkViewModel error: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}

