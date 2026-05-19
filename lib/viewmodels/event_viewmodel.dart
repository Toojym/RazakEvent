import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../models/date_filter.dart';
import '../repositories/event_repository.dart';

class EventViewModel extends ChangeNotifier {
  final EventRepository _repository;
  StreamSubscription<List<EventModel>>? _subscription;

  List<EventModel> events = [];
  bool isLoading = true;
  String? errorMessage;
  DateFilter _activeFilter = const DateFilter.none();

  DateFilter get activeFilter => _activeFilter;

  EventViewModel(this._repository) {
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    isLoading = true;
    notifyListeners();

    _subscription?.cancel();

    _subscription = _repository.watchEvents(filter: _activeFilter).listen(
          (incoming) {
        events = incoming;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        errorMessage = error.toString();
        isLoading = false;
        notifyListeners();
      },
    );
  }

  void filterUpcoming() {
    _activeFilter = const DateFilter.upcoming();
    _subscribeToEvents();
  }

  void filterByRange({required DateTime from, required DateTime to}) {
    _activeFilter = DateFilter.range(from: from, to: to);
    _subscribeToEvents();
  }

  void clearFilter() {
    _activeFilter = const DateFilter.none();
    _subscribeToEvents();
  }

  Future<void> addEvent(EventModel event) async {
    await _repository.addEvent(event);
  }

  Future<void> deleteEvent(String id) async {
    await _repository.deleteEvent(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}