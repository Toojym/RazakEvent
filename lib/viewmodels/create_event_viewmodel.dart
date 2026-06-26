import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../repositories/event_repository.dart';
import '../repositories/storage_repository.dart';
import '../repositories/report_repository.dart';
import '../models/event_model.dart';
import '../models/report_model.dart';

class CreateEventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository = EventRepository();
  final _uuid = const Uuid();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _posterImage;
  XFile? get posterImage => _posterImage;

  PlatformFile? _paperworkFile;
  PlatformFile? get paperworkFile => _paperworkFile;

  Future<void> pickImage(bool isPoster) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        if (isPoster) {
          _posterImage = pickedFile;
          notifyListeners();
        }
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
    bool hasPaperwork = false,
    String category = 'Other',
    double fee = 0.0,
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
      bool finalHasPaperwork = hasPaperwork;

      if (_posterImage != null) {
        final bytes = await _posterImage!.readAsBytes();
        final ext = _posterImage!.name.split('.').last.toLowerCase();
        finalPosterUrl = await storageRepo.uploadEventImage(bytes, ext, isPoster: true);
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
        imageUrl: finalPosterUrl ?? (imageUrl?.trim().isEmpty == true ? null : imageUrl?.trim()),
        posterUrl: finalPosterUrl,
        hasPaperwork: finalHasPaperwork,
        category: category,
        fee: fee,
      );

      await _eventRepository.addEvent(event);
      _posterImage = null;
      _paperworkFile = null;
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
