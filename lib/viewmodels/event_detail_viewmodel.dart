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
  int _totalRegistered = 0;

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
    try {
      if (user != null) {
        _isRegistered = await _registrationRepo.hasRegistered(event.eventId, user.uid);
      }
      _totalRegistered = await _registrationRepo.getRegistrationCountForEvent(event.eventId);
    } catch (e) {
      debugPrint('Error fetching event stats: $e');
    }
    _isLoading = false;
    if (!_isDisposed) notifyListeners();
  }

  // ── Derived Properties for UI ───────────────────────────────────────
  String get formattedDate => DateFormat('dd MMMM yyyy').format(event.date);
  String get startTime => DateFormat('h:mm a').format(event.date);
  
  // Mock data for missing fields
  String get duration {
    if (event.endDate != null) {
      final days = event.endDate!.difference(event.date).inDays;
      return days > 0 ? '$days Day${days > 1 ? 's' : ''}' : '1 Day';
    }
    return '1 Day';
  }
  String get endTime => event.endDate != null ? DateFormat('h:mm a').format(event.endDate!) : DateFormat('h:mm a').format(event.date.add(const Duration(hours: 3)));
  String get status => _isRegistered ? 'Registered' : 'Unregistered';
  String get fee => event.fee == 0 ? 'Free' : 'RM ${event.fee.toStringAsFixed(2)}';

  // Dynamic slots data
  int get filledSlots => _totalRegistered;
  int get emptySlots => (event.maxCapacity ?? 15) - _totalRegistered < 0 ? 0 : (event.maxCapacity ?? 15) - _totalRegistered;
  int get availablePositions => emptySlots;

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
      _totalRegistered++;
    } catch (e) {
      _errorMessage = 'Failed to register: $e';
      debugPrint('Registration error: $e');
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
      if (_totalRegistered > 0) _totalRegistered--;
    } catch (e) {
      _errorMessage = 'Failed to un-register: $e';
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}
