/// Tracks the result of one simulated scan attempt during a stress test.
class StressTestResult {
  /// Index of the simulated user (0–9).
  final int userIdx;

  /// Fake user name used in this simulation.
  final String userName;

  /// Whether the Firestore write succeeded.
  final bool success;

  /// If failed, the error message.
  final String? errorMessage;

  /// Milliseconds from start of test to completion.
  final int durationMs;

  /// The Firestore document ID written (null if failed).
  final String? attendanceId;

  /// Timestamp of when this result was recorded.
  final DateTime timestamp;

  const StressTestResult({
    required this.userIdx,
    required this.userName,
    required this.success,
    this.errorMessage,
    required this.durationMs,
    this.attendanceId,
    required this.timestamp,
  });

  /// "PASS" when success, "FAIL" otherwise.
  String get verdict => success ? 'PASS' : 'FAIL';
}
