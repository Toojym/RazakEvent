import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/event_repository.dart';

class OrganizerProfileViewModel extends ChangeNotifier {
  final EventRepository _eventRepo = EventRepository();
  final UserRepository _userRepo = UserRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  UserModel? _user;
  UserModel? get user => _user;

  int _totalSessionEvents = 0;
  int get totalSessionEvents => _totalSessionEvents;

  int _sem1Events = 0;
  int get sem1Events => _sem1Events;

  int _sem2Events = 0;
  int get sem2Events => _sem2Events;

  int _uploadedPaperworks = 0;
  int get uploadedPaperworks => _uploadedPaperworks;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  OrganizerProfileViewModel() {
    _loadStats();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      _user = await _userRepo.getUser(currentUser.uid);

      // Load all events across the app
      final events = await _eventRepo.getAllEvents();

      final now = DateTime.now();
      // Session logic: Oct-Jan is Sem 1, Mar-Jul is Sem 2.
      // A session starts in October and ends in July next year.
      final currentSessionStartYear = now.month >= 10 ? now.year : now.year - 1;
      final currentSessionStart = DateTime(currentSessionStartYear, 10, 1);
      final currentSessionEnd = DateTime(
        currentSessionStartYear + 1,
        8,
        1,
      ); // Up to end of July

      int sessionCount = 0;
      int sem1Count = 0;
      int sem2Count = 0;
      int paperworkCount = 0;

      for (final event in events) {
        if (event.hasPaperwork) paperworkCount++;

        // Check if event is in current session
        if (event.date.isAfter(currentSessionStart) &&
            event.date.isBefore(currentSessionEnd)) {
          sessionCount++;

          // Sem 1: Oct to Jan
          final sem1End = DateTime(currentSessionStartYear + 1, 2, 1);
          if (event.date.isBefore(sem1End)) {
            sem1Count++;
          }

          // Sem 2: Mar to Jul
          final sem2Start = DateTime(currentSessionStartYear + 1, 3, 1);
          if (event.date.isAfter(sem2Start) ||
              event.date.isAtSameMomentAs(sem2Start)) {
            sem2Count++;
          }
        }
      }

      _totalSessionEvents = sessionCount;
      _sem1Events = sem1Count;
      _sem2Events = sem2Count;
      _uploadedPaperworks = paperworkCount;
    } catch (e) {
      _errorMessage = "Failed to load stats: $e";
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}
