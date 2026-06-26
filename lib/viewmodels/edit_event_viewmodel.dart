import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../models/report_model.dart';
import '../repositories/event_repository.dart';
import '../repositories/storage_repository.dart';
import '../repositories/report_repository.dart';

class EditEventViewModel extends ChangeNotifier {
  final EventRepository _repository = EventRepository();
  final StorageRepository _storageRepo = StorageRepository();
  final ReportRepository _reportRepo = ReportRepository();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PlatformFile? _posterFile;
  PlatformFile? get posterFile => _posterFile;

  PlatformFile? _paperworkFile;
  PlatformFile? get paperworkFile => _paperworkFile;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Pick an image file for the event poster.
  /// Uses FilePicker with withData: true for reliable web support.
  Future<void> pickPoster() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        _posterFile = result.files.first;
        if (!_isDisposed) notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> pickPaperwork() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        _paperworkFile = result.files.first;
        if (!_isDisposed) notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<bool> updateEvent({
    required EventModel originalEvent,
    required String title,
    required String description,
    required String location,
    required DateTime date,
    double fee = 0.0,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      // Keep existing poster URL unless a new poster is picked
      String? finalPosterUrl = originalEvent.posterUrl;
      bool finalHasPaperwork = originalEvent.hasPaperwork;

      // Upload new poster if one was picked
      if (_posterFile != null && _posterFile!.bytes != null) {
        final ext = _posterFile!.extension?.toLowerCase() ?? 'jpg';
        finalPosterUrl = await _storageRepo.uploadEventPoster(_posterFile!.bytes!, ext);
      }

      // Upload new paperwork if one was picked
      if (_paperworkFile != null && _paperworkFile!.bytes != null) {
        final pwUrl = await _storageRepo.uploadEventPaperwork(_paperworkFile!.bytes!, _paperworkFile!.name);
        finalHasPaperwork = true;
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await _reportRepo.saveReport(ReportModel(
            reportId: '',
            eventId: originalEvent.eventId,
            eventName: title.trim(),
            uploaderId: currentUser.uid,
            type: 'Proposal Paperwork',
            uploadedAt: DateTime.now(),
            fileUrl: pwUrl,
            fileName: _paperworkFile!.name,
            approvalStatus: 'approved',
          ));
        }
      }

      final updatedEvent = EventModel(
        eventId: originalEvent.eventId,
        title: title,
        description: description,
        category: originalEvent.category,
        date: date,
        endDate: originalEvent.endDate,
        location: location,
        crewQrCodeData: originalEvent.crewQrCodeData,
        attendeeQrCodeData: originalEvent.attendeeQrCodeData,
        createdBy: originalEvent.createdBy,
        hasPaperwork: finalHasPaperwork,
        posterUrl: finalPosterUrl,
        attendeeMeritPoints: originalEvent.attendeeMeritPoints,
        crewMeritPoints: originalEvent.crewMeritPoints,
        maxCapacity: originalEvent.maxCapacity,
        fee: fee,
      );

      await _repository.updateEvent(updatedEvent);
      _posterFile = null;
      _paperworkFile = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}
