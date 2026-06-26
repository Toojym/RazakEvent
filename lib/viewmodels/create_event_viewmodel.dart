import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../repositories/event_repository.dart';
import '../repositories/storage_repository.dart';
import '../repositories/report_repository.dart';
import '../services/ai_service.dart';
import '../models/event_model.dart';
import '../models/report_model.dart';

class CreateEventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository = EventRepository();
  final _uuid = const Uuid();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAiScanning = false;
  bool get isAiScanning => _isAiScanning;

  XFile? _posterImage;
  XFile? get posterImage => _posterImage;

  XFile? _headerImage;
  XFile? get headerImage => _headerImage;

  PlatformFile? _paperworkFile;
  PlatformFile? get paperworkFile => _paperworkFile;

  Future<Map<String, dynamic>?> scanPosterWithAi() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (pickedFile != null) {
        _posterImage = pickedFile;
        _isAiScanning = true;
        notifyListeners();

        final bytes = await pickedFile.readAsBytes();
        final extractedData = await AiService().extractEventInfoFromPoster(bytes);

        _isAiScanning = false;
        notifyListeners();
        return extractedData;
      }
    } catch (e) {
      _isAiScanning = false;
      notifyListeners();
    }
    return null;
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
        notifyListeners();
      }
    } catch (e) {
      // Handle error
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
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<String?> submitEvent({
    required String title,
    required String description,
    required DateTime date,
    DateTime? endDate,
    required String location,
    required int attendeeMeritPoints,
    required int crewMeritPoints,
    int? maxCapacity,
    String? imageUrl,
    String? posterUrl,
    String? headerUrl,
    bool hasPaperwork = false,
    String category = 'Other',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "User not authenticated";

    _isLoading = true;
    notifyListeners();

    try {
      final String eventId = _uuid.v4();
      final String attendeeQrCodeData = _uuid.v4();
      final String crewQrCodeData = _uuid.v4();

      final StorageRepository storageRepo = StorageRepository();

      String? finalPosterUrl = posterUrl;
      String? finalHeaderUrl = headerUrl;
      bool finalHasPaperwork = hasPaperwork;

      if (_posterImage != null) {
        final bytes = await _posterImage!.readAsBytes();
        final ext = _posterImage!.name.split('.').last.toLowerCase();
        finalPosterUrl = await storageRepo.uploadEventImage(bytes, ext, isPoster: true);
      }

      if (_headerImage != null) {
        final bytes = await _headerImage!.readAsBytes();
        final ext = _headerImage!.name.split('.').last.toLowerCase();
        finalHeaderUrl = await storageRepo.uploadEventImage(bytes, ext, isPoster: false);
      }

      if (_paperworkFile != null && _paperworkFile!.bytes != null) {
        final pwUrl = await storageRepo.uploadEventPaperwork(_paperworkFile!.bytes!, _paperworkFile!.name);
        finalHasPaperwork = true;
        await ReportRepository().saveReport(ReportModel(
          reportId: '',
          eventId: eventId,
          eventName: title.trim(),
          uploaderId: user.uid,
          type: 'Proposal Paperwork',
          uploadedAt: DateTime.now(),
          fileUrl: pwUrl,
          fileName: _paperworkFile!.name,
          approvalStatus: 'approved',
        ));
      }

      final event = EventModel(
        eventId: eventId,
        title: title.trim(),
        description: description.trim(),
        date: date,
        endDate: endDate,
        location: location.trim(),
        attendeeMeritPoints: attendeeMeritPoints,
        crewMeritPoints: crewMeritPoints,
        createdBy: user.uid,
        attendeeQrCodeData: attendeeQrCodeData,
        crewQrCodeData: crewQrCodeData,
        maxCapacity: maxCapacity,
        imageUrl: finalPosterUrl ?? finalHeaderUrl ?? (imageUrl?.trim().isEmpty == true ? null : imageUrl?.trim()),
        posterUrl: finalPosterUrl,
        headerUrl: finalHeaderUrl,
        hasPaperwork: finalHasPaperwork,
        category: category,
      );

      await _eventRepository.addEvent(event);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
