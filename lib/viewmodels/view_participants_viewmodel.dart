import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/user_repository.dart';

import '../repositories/registration_repository.dart';

class ParticipantDetails {
  final String name;
  final String matric;
  final String status;

  ParticipantDetails({required this.name, required this.matric, required this.status});
}

class ViewParticipantsViewModel extends ChangeNotifier {
  final EventModel event;
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final RegistrationRepository _registrationRepo = RegistrationRepository();
  final UserRepository _userRepo = UserRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<ParticipantDetails> _participants = [];
  List<ParticipantDetails> get participants => _participants;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ViewParticipantsViewModel({required this.event}) {
    _loadParticipants();
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadParticipants() async {
    _isLoading = true;
    _errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      final registrations = await _registrationRepo.getRegistrationsForEvent(event.eventId);
      final attendances = await _attendanceRepo.getAttendeesForEvent(event.eventId);
      
      final Map<String, String> userStatusMap = {};
      
      for (final reg in registrations) {
        userStatusMap[reg.userId] = 'Registered';
      }
      
      for (final att in attendances) {
        userStatusMap[att.userId] = 'Attended';
      }
      
      final List<ParticipantDetails> loadedParticipants = [];
      
      for (final userId in userStatusMap.keys) {
        try {
          final user = await _userRepo.getUser(userId);
          if (user != null) {
            loadedParticipants.add(ParticipantDetails(
              name: user.name,
              matric: user.matric,
              status: userStatusMap[userId]!,
            ));
          }
        } catch (e) {
          // Skip user if not found
          debugPrint('Error fetching user $userId: $e');
        }
      }
      
      _participants = loadedParticipants;
    } catch (e) {
      _errorMessage = 'Failed to load participants: $e';
      debugPrint('Error loading participants: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}
