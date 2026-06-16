import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
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

      // Upload file to Firebase Storage
      final fileName = _selectedFile!.name;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('reports/${event.eventId}/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      TaskSnapshot uploadTask;
      if (_selectedFile!.bytes != null) {
        uploadTask = await storageRef.putData(_selectedFile!.bytes!);
      } else if (_selectedFile!.path != null) {
        uploadTask = await storageRef.putFile(File(_selectedFile!.path!));
      } else {
        throw Exception("Cannot read file data");
      }

      final fileUrl = await uploadTask.ref.getDownloadURL();

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
