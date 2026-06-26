import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  XFile? _posterImage;
  XFile? get posterImage => _posterImage;

  XFile? _headerImage;
  XFile? get headerImage => _headerImage;

  PlatformFile? _paperworkFile;
  PlatformFile? get paperworkFile => _paperworkFile;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> pickImage(bool isPoster) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        if (isPoster) {
          _posterImage = pickedFile;
        } else {
          _headerImage = pickedFile;
        }
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
  }) async {
    _isLoading = true;
    _errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      String? finalPosterUrl = originalEvent.posterUrl;
      String? finalHeaderUrl = originalEvent.headerUrl;
      bool finalHasPaperwork = originalEvent.hasPaperwork;

      if (_posterImage != null) {
        final bytes = await _posterImage!.readAsBytes();
        final ext = _posterImage!.name.split('.').last.toLowerCase();
        finalPosterUrl = await _storageRepo.uploadEventImage(bytes, ext, isPoster: true);
      }

      if (_headerImage != null) {
        final bytes = await _headerImage!.readAsBytes();
        final ext = _headerImage!.name.split('.').last.toLowerCase();
        finalHeaderUrl = await _storageRepo.uploadEventImage(bytes, ext, isPoster: false);
      }

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

      final updatedImageUrl = finalPosterUrl ?? finalHeaderUrl ?? originalEvent.imageUrl;

      final updatedEvent = EventModel(
        eventId: originalEvent.eventId,
        title: title,
        description: description,
        category: originalEvent.category,
        date: date,
        location: location,
        imageUrl: updatedImageUrl,
        crewQrCodeData: originalEvent.crewQrCodeData,
        attendeeQrCodeData: originalEvent.attendeeQrCodeData,
        createdBy: originalEvent.createdBy,
        hasPaperwork: finalHasPaperwork,
        posterUrl: finalPosterUrl,
        headerUrl: finalHeaderUrl,
        attendeeMeritPoints: originalEvent.attendeeMeritPoints,
        crewMeritPoints: originalEvent.crewMeritPoints,
        maxCapacity: originalEvent.maxCapacity,
      );

      await _repository.updateEvent(updatedEvent);
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
