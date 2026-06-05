import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/attendance_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  final AttendanceRepository _attendanceRepo;

  ProfileViewModel({
    required UserRepository userRepo,
    required AttendanceRepository attendanceRepo,
  })  : _userRepo = userRepo,
        _attendanceRepo = attendanceRepo {
    _loadProfileData();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  UserModel? _user;
  UserModel? get user => _user;

  int _rank = 0;
  int get rank => _rank;

  int _eventsParticipated = 0;
  int get eventsParticipated => _eventsParticipated;

  int _eventsVolunteered = 0;
  int get eventsVolunteered => _eventsVolunteered;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> _loadProfileData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final uid = currentUser.uid;

        // Fetch user document
        try {
          _user = await _userRepo.getUser(uid);
        } catch (e) {
          _errorMessage = 'Failed to load user: $e';
        }

        // Fetch counts individually so one failure doesn't break the whole profile
        try {
          _eventsParticipated = await _attendanceRepo.getParticipatedCount(uid);
        } catch (e) {
          debugPrint('Error getting participated count: $e');
        }

        try {
          _eventsVolunteered = await _attendanceRepo.getVolunteeredCount(uid);
        } catch (e) {
          debugPrint('Error getting volunteered count: $e');
        }

        // Rank calculation
        if (_user != null) {
          _rank = await _userRepo.getUserRank(_user!.meritPoints);
        }
      }
    } catch (e) {
      _errorMessage = 'Unknown error: $e';
      debugPrint('Error loading profile data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reloads the profile data (useful for pull-to-refresh)
  Future<void> refresh() => _loadProfileData();
}
