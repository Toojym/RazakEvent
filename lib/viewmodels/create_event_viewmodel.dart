import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/event_repository.dart';
import '../models/event_model.dart';

class CreateEventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository = EventRepository();
  final _uuid = const Uuid();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> submitEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required int attendeeMeritPoints,
    required int crewMeritPoints,
    int? maxCapacity,
    String? imageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("You must be logged in to create an event.");
      }

      final String eventId = _uuid.v4();
      final String attendeeQrCodeData = _uuid.v4();
      final String crewQrCodeData = _uuid.v4();

      final event = EventModel(
        eventId: eventId,
        title: title.trim(),
        description: description.trim(),
        date: date,
        location: location.trim(),
        attendeeMeritPoints: attendeeMeritPoints,
        crewMeritPoints: crewMeritPoints,
        createdBy: user.uid,
        attendeeQrCodeData: attendeeQrCodeData,
        crewQrCodeData: crewQrCodeData,
        maxCapacity: maxCapacity,
        imageUrl: imageUrl?.trim().isEmpty == true ? null : imageUrl?.trim(),
      );

      await _eventRepository.addEvent(event);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
