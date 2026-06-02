import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/stress_test_result.dart';
import '../widgets/scan_result_dialog.dart';

/// Simulates 10 concurrent QR scan attempts against Firestore
/// to test for race conditions, write conflicts, and performance.
///
/// Run this screen after connecting to Firebase to validate that
/// the attendance system can handle a busy event check-in.
class StressTestView extends StatefulWidget {
  const StressTestView({super.key});

  @override
  State<StressTestView> createState() => _StressTestViewState();
}

class _StressTestViewState extends State<StressTestView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  bool _isRunning = false;
  bool _isComplete = false;
  final List<StressTestResult> _results = [];
  int _totalElapsed = 0;

  // ── Test configuration ──────────────────────────────────────────
  static const int _numUsers = 10;
  static const String _testEventId = 'stress-test-event-001';
  static const String _testEventName = 'Stress Test Event';

  final List<String> _fakeUsers = const [
    'Ahmad Razak',
    'Sarah Binti Ali',
    'Muhammad Faris',
    'Nurul Aisyah',
    'Ameer Hamzah',
    'Fatimah Zahra',
    'Ismail Bin Yusof',
    'Puteri Sofea',
    'Haziq Danial',
    'Aina Majidah',
  ];

  // ── Run the stress test ─────────────────────────────────────────
  Future<void> _runStressTest() async {
    setState(() {
      _isRunning = true;
      _isComplete = false;
      _results.clear();
      _totalElapsed = 0;
    });

    final stopwatch = Stopwatch()..start();

    // Launch all 10 scans simultaneously
    final futures = <Future<StressTestResult>>[];

    for (int i = 0; i < _numUsers; i++) {
      futures.add(_simulateScan(i));
    }

    // Wait for ALL to finish
    final results = await Future.wait(futures);

    stopwatch.stop();

    setState(() {
      _results = results;
      _totalElapsed = stopwatch.elapsedMilliseconds;
      _isRunning = false;
      _isComplete = true;
    });
  }

  /// Simulates a single user scanning the QR code and writing to Firestore.
  Future<StressTestResult> _simulateScan(int idx) async {
    final scanStart = DateTime.now();
    final stopwatch = Stopwatch()..start();

    try {
      final attendanceId = _uuid.v4();

      await _firestore.collection('attendances').doc(attendanceId).set({
        'eventId': _testEventId,
        'userId': 'stress_user_$idx',
        'userName': _fakeUsers[idx],
        'scannedAt': FieldValue.serverTimestamp(),
        'pointsAwarded': 1,
        'joinRole': idx < 7 ? 'attendee' : 'crew', // 7 attendees, 3 crew
        'stressTest': true, // flag so real data isn't polluted
      });

      stopwatch.stop();

      return StressTestResult(
        userIdx: idx,
        userName: _fakeUsers[idx],
        success: true,
        durationMs: stopwatch.elapsedMilliseconds,
        attendanceId: attendanceId,
        timestamp: scanStart,
      );
    } catch (e) {
      stopwatch.stop();

      return StressTestResult(
        userIdx: idx,
        userName: _fakeUsers[idx],
        success: false,
        errorMessage: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
        timestamp: scanStart,
      );
    }
  }

  // ── Cleanup test data ──────────────────────────────────────────
  Future<void> _cleanupTestData() async {
    try {
      final snapshot = await _firestore
          .collection('attendances')
          .where('stressTest', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleaned up ${snapshot.docs.size} test records.'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _results.clear();
        _isComplete = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cleanup failed: $e')),
      );
    }
  }

  // ── Show a sample dialog ────────────────────────────────────────
  void _showSampleDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      pageBuilder: (_, __, ___) => ScanResultDialog(
        result: ScanResult(
          type: ScanResultType.success,
          userName: 'Ahmad Razak',
          eventName: _testEventName,
          pointsAwarded: 1,
          joinRole: 'attendee',
          scannedAt: DateTime.now(),
        ),
      ),
    );
  }

  // ── Computed stats ──────────────────────────────────────────────
  int get _passCount => _results.where((r) => r.success).length;
  int get _failCount => _results.where((r) => !r.success).length;
  int get _avgTime => _results.isEmpty
      ? 0
      : _results.map((r) => r.durationMs).reduce((a, b) => a + b) ~/ _results.length;
  int get _maxTime =>
      _results.isEmpty ? 0 : _results.map((r) => r.durationMs).reduce((a, b) => a > b ? a : b);
  int get _minTime =>
      _results.isEmpty ? 0 : _results.map((r) => r.durationMs).reduce((a, b) => a < b ? a : b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          'RE-40 Stress Test',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isComplete)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              tooltip: 'Cleanup test data',
              onPressed: _cleanupTestData,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Info card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Simulates $_numUsers users scanning into the same '
                      'event simultaneously. Tests Firestore concurrency, '
                      'write speed, and error handling.'),
                  SizedBox(height: 8),
                  Text('Event: $_testEventName',
                      style: TextStyle(color: Colors.white54)),
                  Text('Users: 10 (7 attendees + 3 crew)',
                      style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Run button ─────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _isRunning ? null : _runStressTest,
              icon: _isRunning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(
                _isRunning
                    ? 'Running...'
                    : _isComplete
                        ? 'Re-run Stress Test'
                        : 'Start Stress Test ($_numUsers users)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Preview dialog button ───────────────────────────
            OutlinedButton.icon(
              onPressed: _showSampleDialog,
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('Preview Success Dialog (RE-39)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white54,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Results ────────────────────────────────────────
            if (_isComplete) ...[
              _buildSummaryCard(),
              const SizedBox(height: 12),
              Expanded(child: _buildResultsList()),
            ] else if (_isRunning)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.deepPurple),
                      SizedBox(height: 16),
                      Text('Scanning...',
                          style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Summary card ─────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    final allPassed = _passCount == _numUsers;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: allPassed ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: allPassed ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allPassed ? Icons.check_circle_rounded : Icons.error_rounded,
                color: allPassed ? Colors.green : Colors.redAccent,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                allPassed ? 'ALL TESTS PASSED' : 'SOME TESTS FAILED',
                style: TextStyle(
                  color: allPassed ? Colors.green : Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _statRow('Total Time', '${_totalElapsed}ms'),
          _statRow('Passed', '$_passCount / $_numUsers'),
          _statRow('Failed', '$_failCount'),
          _statRow('Avg per scan', '${_avgTime}ms'),
          _statRow('Fastest', '${_minTime}ms'),
          _statRow('Slowest', '${_maxTime}ms'),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Results list ────────────────────────────────────────────────
  Widget _buildResultsList() {
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final r = _results[index];
        final passed = r.success;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: passed
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              // Status icon
              Icon(
                passed ? Icons.check_circle : Icons.cancel,
                color: passed ? Colors.green : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 10),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${r.userIdx + 1}. ${r.userName}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    if (!passed && r.errorMessage != null)
                      Text(
                        r.errorMessage!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Timing
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${r.durationMs}ms',
                    style: TextStyle(
                      color: r.durationMs > 1000
                          ? Colors.amber
                          : Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: passed
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      r.verdict,
                      style: TextStyle(
                        color: passed ? Colors.green : Colors.redAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
