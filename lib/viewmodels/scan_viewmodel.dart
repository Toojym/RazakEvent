import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../repositories/event_repository.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/user_repository.dart';
import '../models/attendance_model.dart';
import '../models/event_model.dart';

enum ScanStatus { scanning, processing, success, error }

class ScanViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;
  final AttendanceRepository _attendanceRepo;
  final UserRepository _userRepo;

  ScanStatus _status = ScanStatus.scanning;
  String? _message;
  EventModel? _scannedEvent;

  /// Minimum time between accepting consecutive scans.
  static const _kScanCooldown = Duration(seconds: 2);

  /// Tracks the last time a scan was accepted for processing.
  DateTime? _lastScanTime;

  /// In-memory set of QR codes currently being processed or already processed
  /// in this session. Prevents duplicate Firestore writes when the same code
  /// is scanned rapidly before the first network round-trip completes.
  final Set<String> _processedQrCodes = {};

  ScanViewModel({
    required EventRepository eventRepo,
    required AttendanceRepository attendanceRepo,
    required UserRepository userRepo,
  })  : _eventRepo = eventRepo,
        _attendanceRepo = attendanceRepo,
        _userRepo = userRepo;

  ScanStatus get status => _status;
  String? get message => _message;
  EventModel? get scannedEvent => _scannedEvent;

  void resumeScanning() {
    _status = ScanStatus.scanning;
    _message = null;
    _scannedEvent = null;
    // Clear processed codes so re-scanning is possible after explicit reset.
    _processedQrCodes.clear();
    notifyListeners();
  }

  Future<void> processQrCode(String qrData) async {
    final now = DateTime.now();

    // ── Guard 1: only accept scans while in `scanning` state ──
    if (_status != ScanStatus.scanning) return;

    // ── Guard 2: cooldown – reject rapid-fire scans ──
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!) < _kScanCooldown) {
      _logScan('COOLDOWN_BLOCKED', qrData: qrData, timestamp: now);
      return;
    }

    // ── Guard 3: in-memory dedup – block codes already in-flight ──
    if (_processedQrCodes.contains(qrData)) {
      _logScan('LOCAL_DUPLICATE_BLOCKED', qrData: qrData, timestamp: now);
      return;
    }

    // ── Guard 4: validate QR format (must be a UUID) ──
    final isUuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(qrData);
    if (!isUuid) {
      _status = ScanStatus.error;
      _message = 'Invalid QR code. Please scan a valid participant or crew QR code.';
      _logScan('ERROR_INVALID_FORMAT', qrData: qrData, timestamp: now);
      notifyListeners();
      return;
    }

    _lastScanTime = now;
    _processedQrCodes.add(qrData);
    _logScan('SCAN_ACCEPTED', qrData: qrData, timestamp: now);

    _status = ScanStatus.processing;
    _message = 'Verifying QR code...';
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _status = ScanStatus.error;
        _message = 'You must be logged in to record attendance.';
        _logScan('ERROR_NOT_LOGGED_IN', qrData: qrData, timestamp: now);
        notifyListeners();
        return;
      }

      // 1. Look up the event by QR data
      final event = await _eventRepo.findByQrCodeData(qrData);
      if (event == null) {
        _status = ScanStatus.error;
        _message = 'Invalid QR code. Event not found.';
        _logScan('ERROR_EVENT_NOT_FOUND', qrData: qrData, timestamp: now);
        notifyListeners();
        return;
      }

      _scannedEvent = event;

      // Determine role based on which QR matched
      final isCrew = (event.crewQrCodeData == qrData);
      final role = isCrew ? 'crew' : 'attendee';
      final points = isCrew ? event.crewMeritPoints : event.attendeeMeritPoints;

      // 2. Check for duplicate attendance (server-side)
      final isDuplicate = await _attendanceRepo.hasDuplicateAttendance(
        eventId: event.eventId,
        userId: user.uid,
      );

      if (isDuplicate) {
        _status = ScanStatus.error;
        _message = 'You have already recorded attendance for ${event.title}.';
        _logScan(
          'SERVER_DUPLICATE_BLOCKED',
          qrData: qrData,
          timestamp: now,
          extra: 'eventId=${event.eventId}, userId=${user.uid}',
        );
        notifyListeners();
        return;
      }

      // 3. Record attendance
      final scannedAt = DateTime.now();
      final attendance = AttendanceModel(
        attendanceId: const Uuid().v4(),
        eventId: event.eventId,
        userId: user.uid,
        scannedAt: scannedAt,
        pointsAwarded: points,
        joinRole: role,
      );

      await _attendanceRepo.recordAttendance(attendance);

      // 4. Add merit points to the user's profile
      await _userRepo.addMeritPoints(uid: user.uid, points: points);

      _status = ScanStatus.success;
      _message =
          'Successfully recorded attendance for ${event.title} as $role. You earned $points merit points!';
      _logScan(
        'SUCCESS',
        qrData: qrData,
        timestamp: scannedAt,
        extra:
            'eventId=${event.eventId}, role=$role, points=$points, attendanceId=${attendance.attendanceId}',
      );
      notifyListeners();
    } catch (e) {
      _status = ScanStatus.error;
      _message =
          'An error occurred while processing the QR code. Please try again.';
      _logScan(
        'ERROR_EXCEPTION',
        qrData: qrData,
        timestamp: now,
        extra: e.toString(),
      );
      notifyListeners();
    }
  }

  /// Emits a structured log entry for every scan lifecycle event.
  void _logScan(
    String event, {
    required String qrData,
    required DateTime timestamp,
    String? extra,
  }) {
    final buffer = StringBuffer()
      ..write('[ScanViewModel] $event ')
      ..write('| ts=${timestamp.toIso8601String()} ')
      ..write('| qr=${qrData.length > 40 ? '${qrData.substring(0, 40)}…' : qrData}');
    if (extra != null) {
      buffer.write(' | $extra');
    }
    developer.log(
      buffer.toString(),
      name: 'QRScanner',
      time: timestamp,
    );
  }
}
