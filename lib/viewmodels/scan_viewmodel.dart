import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../repositories/event_repository.dart';
import '../repositories/attendance_repository.dart';
import '../models/attendance_model.dart';
import '../models/event_model.dart';

enum ScanStatus { scanning, processing, success, error }

class ScanViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;
  final AttendanceRepository _attendanceRepo;

  ScanStatus _status = ScanStatus.scanning;
  String? _message;
  EventModel? _scannedEvent;

  ScanViewModel({
    required EventRepository eventRepo,
    required AttendanceRepository attendanceRepo,
  })  : _eventRepo = eventRepo,
        _attendanceRepo = attendanceRepo;

  ScanStatus get status => _status;
  String? get message => _message;
  EventModel? get scannedEvent => _scannedEvent;

  void resumeScanning() {
    _status = ScanStatus.scanning;
    _message = null;
    _scannedEvent = null;
    notifyListeners();
  }

  Future<void> processQrCode(String qrData) async {
    if (_status != ScanStatus.scanning) return;

    _status = ScanStatus.processing;
    _message = 'Verifying QR code...';
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _status = ScanStatus.error;
        _message = 'You must be logged in to record attendance.';
        notifyListeners();
        return;
      }

      // 1. Look up the event by QR data
      final event = await _eventRepo.findByQrCodeData(qrData);
      if (event == null) {
        _status = ScanStatus.error;
        _message = 'Invalid QR code. Event not found.';
        notifyListeners();
        return;
      }

      _scannedEvent = event;

      // Determine role based on which QR matched
      final isCrew = (event.crewQrCodeData == qrData);
      final role = isCrew ? 'crew' : 'attendee';
      final points = isCrew ? event.crewMeritPoints : event.attendeeMeritPoints;

      // 2. Check for duplicate attendance
      final isDuplicate = await _attendanceRepo.hasDuplicateAttendance(
        eventId: event.eventId,
        userId: user.uid,
      );

      if (isDuplicate) {
        _status = ScanStatus.error;
        _message = 'You have already recorded attendance for ${event.title}.';
        notifyListeners();
        return;
      }

      // 3. Record attendance
      final attendance = AttendanceModel(
        attendanceId: const Uuid().v4(),
        eventId: event.eventId,
        userId: user.uid,
        scannedAt: DateTime.now(),
        pointsAwarded: points,
        joinRole: role,
      );

      await _attendanceRepo.recordAttendance(attendance);

      _status = ScanStatus.success;
      _message = 'Successfully recorded attendance for ${event.title} as $role. You earned $points merit points!';
      notifyListeners();
    } catch (e) {
      _status = ScanStatus.error;
      _message = 'An error occurred while processing the QR code. Please try again.';
      notifyListeners();
    }
  }
}
