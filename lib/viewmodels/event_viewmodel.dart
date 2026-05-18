import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

class EventViewModel extends ChangeNotifier {
  final EventRepository _repository;
  StreamSubscription<List<Event>>? _subscription;

  List<Event> events = [];
  bool isLoading = true;
  String? errorMessage;

  EventViewModel(this._repository) {
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    _subscription = _repository.watchEvents().listen(
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

  Future<void> addEvent(Event event) async {
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