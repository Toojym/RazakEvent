import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/registration_repository.dart';

class EventDetailViewModel extends ChangeNotifier {
  final EventModel event;
  final RegistrationRepository _registrationRepo = RegistrationRepository();

  bool _isLoading = true;
  String? _errorMessage;
  bool _isRegistered = false;

  EventDetailViewModel({required this.event}) {
    _checkRegistrationStatus();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isRegistered => _isRegistered;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _checkRegistrationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        _isRegistered = await _registrationRepo.hasRegistered(event.eventId, user.uid);
      } catch (e) {
        // ignore
      }
    }
    _isLoading = false;
    if (!_isDisposed) notifyListeners();
  }

  // ── Derived Properties for UI ───────────────────────────────────────
  String get formattedDate => DateFormat('dd MMMM yyyy').format(event.date);
  String get startTime => DateFormat('h:mm a').format(event.date);
  
  // Mock data for missing fields
  String get duration => '1 Day'; // Default mock
  String get endTime => DateFormat('h:mm a').format(event.date.add(const Duration(hours: 3))); // Mock 3 hours
  String get status => 'Unregistered'; // Mock status
  String get fee => 'RM 5.00'; // Mock fee

  // Mock slots data
  int get filledSlots => 67;
  int get emptySlots => 3;
  int get availablePositions => 5;

  Future<void> register() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = "You must be logged in to register.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _registrationRepo.registerUser(event.eventId, user.uid);
      _isRegistered = true;
    } catch (e) {
      _errorMessage = 'Failed to register: $e';
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> unregister() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _registrationRepo.unregisterUser(event.eventId, user.uid);
      _isRegistered = false;
    } catch (e) {
      _errorMessage = 'Failed to un-register: $e';
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}
