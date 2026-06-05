import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'package:intl/intl.dart';

class EventDetailViewModel extends ChangeNotifier {
  final EventModel event;

  bool _isLoading = false;
  String? _errorMessage;

  EventDetailViewModel({required this.event});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Implement actual registration logic
      // e.g., await _registrationRepo.registerUserForEvent(event.eventId, userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to register: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
