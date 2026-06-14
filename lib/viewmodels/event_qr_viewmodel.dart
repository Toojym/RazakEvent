import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/user_repository.dart';

class AttendeeDetails {
  final String name;
  final String matric;
  final String role; // 'attendee' or 'crew'

  AttendeeDetails({required this.name, required this.matric, required this.role});
}

class EventQrViewModel extends ChangeNotifier {
  final EventModel event;
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final UserRepository _userRepo = UserRepository();

  bool _isCrewToggle = false;
  bool get isCrewToggle => _isCrewToggle;

  bool _showingAttendeesList = false;
  bool get showingAttendeesList => _showingAttendeesList;

  List<AttendeeDetails> _allAttendees = [];
  
  // Computed list based on toggle
  List<AttendeeDetails> get filteredAttendees => 
      _allAttendees.where((a) => _isCrewToggle ? a.role == 'crew' : a.role == 'attendee').toList();

  int get totalScanned => filteredAttendees.length;

  String _timeRemaining = "00 : 00 : 00";
  String get timeRemaining => _timeRemaining;

  Timer? _timer;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isDisposed = false;

  EventQrViewModel({required this.event}) {
    _startTimer();
    _loadAttendees();
  }

  void toggleRole(bool isCrew) {
    _isCrewToggle = isCrew;
    if (!_isDisposed) notifyListeners();
  }

  void toggleListView(bool showList) {
    _showingAttendeesList = showList;
    if (!_isDisposed) notifyListeners();
  }

  void _startTimer() {
    // Calculate expiration: Midnight of the last day.
    // E.g., if endDate is July 8th, expiration is July 9th 00:00:00
    final targetDate = event.endDate ?? event.date;
    final expiration = DateTime(targetDate.year, targetDate.month, targetDate.day + 1);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final diff = expiration.difference(now);

      if (diff.isNegative) {
        _timeRemaining = "00 : 00 : 00";
        _timer?.cancel();
      } else {
        final hours = diff.inHours.toString().padLeft(2, '0');
        final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
        _timeRemaining = "$hours : $minutes : $seconds";
      }
      if (!_isDisposed) notifyListeners();
    });
  }

  Future<void> _loadAttendees() async {
    _isLoading = true;
    if (!_isDisposed) notifyListeners();

    try {
      final attendances = await _attendanceRepo.getAttendeesForEvent(event.eventId);
      
      final List<AttendeeDetails> loaded = [];
      for (final att in attendances) {
        try {
          final user = await _userRepo.getUser(att.userId);
          if (user != null) {
            loaded.add(AttendeeDetails(
              name: user.name,
              matric: user.matric,
              role: att.joinRole,
            ));
          }
        } catch (e) {
          debugPrint('Error fetching user ${att.userId}: $e');
        }
      }
      
      _allAttendees = loaded;
    } catch (e) {
      debugPrint('Error loading attendees: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
