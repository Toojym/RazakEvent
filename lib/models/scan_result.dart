enum ScanResultType {
  success,
  alreadyScanned,
  invalidQr,
  networkError,
}

class ScanResult {
  final ScanResultType type;
  final String? userName;
  final String? eventName;
  final int? pointsAwarded;
  final String? joinRole;
  final DateTime? scannedAt;
  final String? errorMessage;

  const ScanResult({
    required this.type,
    this.userName,
    this.eventName,
    this.pointsAwarded,
    this.joinRole,
    this.scannedAt,
    this.errorMessage,
  });
}