import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_model.dart';
import '../models/event_model.dart';
import '../repositories/report_repository.dart';
import '../repositories/event_repository.dart';

class ReportDetails {
  final ReportModel report;
  final EventModel? event;
  final String statusText;
  final Color statusColor;

  ReportDetails({
    required this.report,
    required this.event,
    required this.statusText,
    required this.statusColor,
  });
}

class ViewReportsViewModel extends ChangeNotifier {
  final ReportRepository _reportRepo = ReportRepository();
  final EventRepository _eventRepo = EventRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ReportDetails> _reports = [];
  List<ReportDetails> get reports => _reports;

  bool _isDisposed = false;

  ViewReportsViewModel() {
    _loadReports();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadReports() async {
    _isLoading = true;
    _errorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final reportModels = await _reportRepo.getReportsForOrganizer(user.uid);
      
      final List<ReportDetails> loadedReports = [];
      
      for (final report in reportModels) {
        EventModel? event;
        try {
          event = await _eventRepo.getEvent(report.eventId);
        } catch (e) {
          debugPrint('Failed to load event for report: $e');
        }

        // Calculate early/late status
        String statusText = 'Unknown Status';
        Color statusColor = Colors.white70;

        if (event != null) {
          final difference = event.date.difference(report.uploadedAt).inDays;
          if (difference > 0) {
            statusText = 'Uploaded $difference days early';
            statusColor = const Color(0xFF4CAF50); // Greenish
          } else if (difference < 0) {
            statusText = 'Uploaded ${difference.abs()} days late';
            statusColor = const Color(0xFFE57373); // Reddish
          } else {
            statusText = 'Uploaded today';
            statusColor = const Color(0xFF4CAF50);
          }
        }

        loadedReports.add(ReportDetails(
          report: report,
          event: event,
          statusText: statusText,
          statusColor: statusColor,
        ));
      }

      _reports = loadedReports;
    } catch (e) {
      _errorMessage = "Failed to load reports: $e";
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}
