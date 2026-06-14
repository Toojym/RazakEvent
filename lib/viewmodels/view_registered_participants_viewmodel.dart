import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/registration_repository.dart';
import '../repositories/user_repository.dart';

class RegisteredParticipantDetails {
  final String name;
  final String matric;

  RegisteredParticipantDetails({required this.name, required this.matric});
}

class ViewRegisteredParticipantsViewModel extends ChangeNotifier {
  final EventModel event;
  final RegistrationRepository _registrationRepo = RegistrationRepository();
  final UserRepository _userRepo = UserRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<RegisteredParticipantDetails> _participants = [];
  List<RegisteredParticipantDetails> get participants => _participants;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ViewRegisteredParticipantsViewModel({required this.event}) {
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
      
      final List<RegisteredParticipantDetails> loadedParticipants = [];
      
      for (final reg in registrations) {
        try {
          final user = await _userRepo.getUser(reg.userId);
          if (user != null) {
            loadedParticipants.add(RegisteredParticipantDetails(
              name: user.name,
              matric: user.matric,
            ));
          }
        } catch (e) {
          debugPrint('Error fetching user ${reg.userId}: $e');
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
