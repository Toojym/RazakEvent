import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  StreamSubscription<List<UserModel>>? _sub;

  List<UserModel> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  /// The UID of the currently logged-in user, used to highlight their row.
  final String? _currentUid = FirebaseAuth.instance.currentUser?.uid;

  LeaderboardViewModel(this._userRepo) {
    _sub = _userRepo.watchLeaderboard(limit: 10).listen(
      (users) {
        _users = users;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load leaderboard.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ── Exposed state ──────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUid => _currentUid;

  /// Top 3 users for the podium. Returns up to 3 entries.
  List<UserModel> get podiumUsers =>
      _users.length >= 3 ? _users.sublist(0, 3) : List.from(_users);

  /// Users ranked 4th and below (for the list section).
  List<UserModel> get remainingUsers =>
      _users.length > 3 ? _users.sublist(3) : [];

  /// Total number of ranked users available.
  int get totalUsers => _users.length;
}
