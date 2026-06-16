import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/report_model.dart';
import '../repositories/report_repository.dart';

class AdminEventReportsViewModel extends ChangeNotifier {
  final EventModel event;
  final ReportRepository _reportRepo = ReportRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<ReportModel> _reports = [];
  List<ReportModel> get reports => _reports;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  AdminEventReportsViewModel({required this.event}) {
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
      _reports = await _reportRepo.getReportsForEvent(event.eventId);
    } catch (e) {
      _errorMessage = 'Failed to load reports: $e';
      debugPrint('Error loading reports for event ${event.eventId}: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }
}
