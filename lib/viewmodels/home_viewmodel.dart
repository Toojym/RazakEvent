import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import '../repositories/report_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeViewModel extends ChangeNotifier {
  final EventRepository _repository;
  final ReportRepository _reportRepo = ReportRepository();

  StreamSubscription<List<EventModel>>? _sub;
  StreamSubscription? _reportSub;

  List<EventModel> _events = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  int _uploadedReportsCount = 0;

  HomeViewModel(this._repository) {
    // Load all events once and keep them live
    _sub = _repository
        .watchEvents()
        .listen((events) {
          _events = events;
          _isLoading = false;
          notifyListeners();
        }, onError: (error) {
          _isLoading = false;
          notifyListeners();
        });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _reportSub = _reportRepo.watchReportsForOrganizer(currentUser.uid).listen((reports) {
        _uploadedReportsCount = reports.length;
        notifyListeners();
      }, onError: (error) {});
    }

    FirebaseAuth.instance.authStateChanges().listen((user) {
      _reportSub?.cancel();
      if (user != null) {
        _reportSub = _reportRepo.watchReportsForOrganizer(user.uid).listen((reports) {
          _uploadedReportsCount = reports.length;
          notifyListeners();
        }, onError: (error) {});
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _reportSub?.cancel();
    super.dispose();
  }

  // ── Exposed state ────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  // ── Organizer Home Data ──────────────────────────────────────────
  int get activeEventsCount {
    return organizerUpcomingEvents.length;
  }
  
  List<EventModel> get allUpcomingEvents {
    final now = DateTime.now().subtract(const Duration(hours: 1));
    return _events.where((e) => e.date.isAfter(now)).toList();
  }
  
  List<EventModel> get organizerUpcomingEvents {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final now = DateTime.now().subtract(const Duration(hours: 1));
    return _events.where((e) => e.createdBy == uid && e.date.isAfter(now)).toList();
  }

  int get uploadedReportsCount => _uploadedReportsCount;
  
  int get uploadedPaperworkCount {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;
    return _events.where((e) => e.createdBy == uid && e.hasPaperwork).length;
  }

  // ── Featured event — soonest upcoming event ──────────────────────
  EventModel? get featuredEvent => allUpcomingEvents.isNotEmpty ? allUpcomingEvents.first : null;

  // ── "What's Happening This Week?" ────────────────────────────────
  // Events within the next 7 days, filtered by selected category
  List<EventModel> get thisWeekEvents {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    var list = _events
        .where((e) => e.date.isAfter(now) && e.date.isBefore(weekEnd))
        .toList();
    if (_selectedCategory != 'All') {
      list = list.where((e) => e.category == _selectedCategory).toList();
    }
    return list;
  }

  // ── "Coming Soon!" ────────────────────────────────────────────────
  // Events more than 7 days away
  List<EventModel> get comingSoonEvents {
    final weekEnd = DateTime.now().add(const Duration(days: 7));
    return _events.where((e) => e.date.isAfter(weekEnd)).toList();
  }

  // ── Events filtered by a specific category ───────────────────────
  List<EventModel> eventsByCategory(String category) =>
      _events.where((e) => e.category == category).toList();

  // ── Categories that actually have events ─────────────────────────
  List<String> get availableFilterCategories {
    final cats =
        _events
            .map((e) => e.category)
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...cats];
  }

  // ── Category sections (only categories with at least 1 event) ────
  List<String> get categoriesWithEvents {
    return EventCategories.all
        .where((cat) => _events.any((e) => e.category == cat))
        .toList();
  }

  // ── Update selected category filter ──────────────────────────────
  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }
}
