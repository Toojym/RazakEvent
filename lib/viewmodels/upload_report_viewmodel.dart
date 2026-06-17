import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../models/report_model.dart';
import '../models/event_model.dart';
import '../repositories/report_repository.dart';

class UploadReportViewModel extends ChangeNotifier {
  final ReportRepository _reportRepo = ReportRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PlatformFile? _selectedFile;
  PlatformFile? get selectedFile => _selectedFile;

  bool _isDisposed = false;

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result != null && result.files.isNotEmpty) {
        _selectedFile = result.files.first;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to pick file: $e";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<bool> uploadReport({
    required EventModel? event,
    required String type,
  }) async {
    if (event == null) {
      _errorMessage = "Please select an event.";
      notifyListeners();
      return false;
    }

    if (_selectedFile == null) {
      _errorMessage = "Please select a file to upload.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final fileName = _selectedFile!.name;
      final fileUrl = "";

      final report = ReportModel(
        reportId: '',
        eventId: event.eventId,
        eventName: event.title,
        uploaderId: user.uid,
        type: type,
        uploadedAt: DateTime.now(),
        fileUrl: fileUrl,
        fileName: fileName,
      );

      await _reportRepo.saveReport(report);
      return true;
    } catch (e) {
      _errorMessage = "Failed to upload report: $e";
      return false;
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}
