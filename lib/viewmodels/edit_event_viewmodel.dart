import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

class EditEventViewModel extends ChangeNotifier {
  final EventRepository _repository = EventRepository();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<bool> updateEvent({
    required EventModel originalEvent,
    required String title,
    required String description,
    required String location,
    required DateTime date,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      final updatedEvent = EventModel(
        eventId: originalEvent.eventId,
        title: title,
        description: description,
        category: originalEvent.category,
        date: date,
        location: location,
        imageUrl: originalEvent.imageUrl,
        crewQrCodeData: originalEvent.crewQrCodeData,
        attendeeQrCodeData: originalEvent.attendeeQrCodeData,
        createdBy: originalEvent.createdBy,
        hasPaperwork: originalEvent.hasPaperwork,
        posterUrl: originalEvent.posterUrl,
        headerUrl: originalEvent.headerUrl,
        attendeeMeritPoints: originalEvent.attendeeMeritPoints,
        crewMeritPoints: originalEvent.crewMeritPoints,
        maxCapacity: originalEvent.maxCapacity,
      );

      await _repository.updateEvent(updatedEvent);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}
