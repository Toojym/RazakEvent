import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/event_repository.dart';
import '../models/event_model.dart';

class CreateEventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository = EventRepository();
  final _uuid = const Uuid();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _posterImage;
  XFile? get posterImage => _posterImage;

  XFile? _headerImage;
  XFile? get headerImage => _headerImage;

  Future<void> pickImage(bool isPoster) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (pickedFile != null) {
        if (isPoster) {
          _posterImage = pickedFile;
        } else {
          _headerImage = pickedFile;
        }
        notifyListeners();
      }
    } catch (e) {
      // Ignored for now
    }
  }

  Future<String?> submitEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required int attendeeMeritPoints,
    required int crewMeritPoints,
    int? maxCapacity,
    String? imageUrl,
    required String category,
    bool hasPaperwork = false,
    String? posterUrl,
    String? headerUrl,
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

      String? finalPosterUrl = posterUrl;
      String? finalHeaderUrl = headerUrl;

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
        imageUrl: finalPosterUrl ?? finalHeaderUrl ?? (imageUrl?.trim().isEmpty == true ? null : imageUrl?.trim()),
        posterUrl: finalPosterUrl,
        headerUrl: finalHeaderUrl,
        hasPaperwork: hasPaperwork,
        category: category,
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
