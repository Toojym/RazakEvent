import 'package:mobile_scanner/mobile_scanner.dart';

/// Pre-configured scanner settings optimized for speed over quality.
///
/// Pass these directly into [MobileScannerController]:
/// ```dart
/// final controller = MobileScannerController(
///   detectionSpeed: QrScannerConfig.detectionSpeed,
///   detectionTimeoutMs: QrScannerConfig.detectionTimeoutMs,
///   facing: QrScannerConfig.facing,
///   torchEnabled: QrScannerConfig.torchEnabled,
///   formats: QrScannerConfig.formats,
/// );
/// ```
///
/// Also call [QrScannerConfig.optimizeResolution] before starting the scanner.
class QrScannerConfig {
  QrScannerConfig._();

  // ── Speed-focused settings ──────────────────────────────────────

  /// Speed = detection speed, not quality.
  /// Options: noDuplicates, normal, unrestricted
  static const DetectionSpeed detectionSpeed = DetectionSpeed.noDuplicates;

  /// Minimum milliseconds between consecutive scans.
  /// 250ms prevents the same code from being read twice in rapid succession
  /// (also helps with RE-36 double-scan prevention).
  static const int detectionTimeoutMs = 250;

  /// Use the back camera (primary, usually higher quality).
  static const CameraFacing facing = CameraFacing.back;

  /// Keep torch off by default — saves battery and reduces glare.
  static const bool torchEnabled = false;

  /// Only scan for QR codes — ignores barcodes, Data Matrix, etc.
  /// Restricting formats significantly speeds up the analyzer.
  static const List<BarcodeFormat> formats = [BarcodeFormat.qrCode];

  // ── Scan zone optimization ────────────────────────────────────

  /// Crop the camera frame to the center 60% where the QR code
  /// is most likely to appear. Smaller region = faster analysis.
  ///
  /// Usage in your scanner view:
  /// ```dart
  /// MobileScanner(
  ///   controller: controller,
  ///   scanWindow: QrScannerConfig.scanWindow,
  ///   ...
  /// )
  /// ```
  static Rect get scanWindow => Rect.fromCenter(
        center: Offset.zero,
        width: 400,
        height: 300,
      );

  // ── Resolution optimization ────────────────────────────────────

  /// Set a moderate resolution. High resolutions look good but
  /// take longer to analyze frame-by-frame.
  ///
  /// Call this BEFORE starting the scanner:
  /// ```dart
  /// await QrScannerConfig.optimizeResolution(controller);
  /// await controller.start();
  /// ```
  static Future<void> optimizeResolution(
      MobileScannerController controller) async {
    // Use 720p as a sweet spot — fast enough for real-time scanning
    // while still capturing enough detail for QR codes.
    await controller.setZoomScale(0.0);
  }

  // ── Debounce helper for RE-36 (double-scan prevention) ──────────

  /// Timestamp of the last successful scan.
  static DateTime? _lastScanTime;

  /// Minimum cooldown between two accepted scans.
  static const Duration cooldown = Duration(seconds: 2);

  /// Returns true if enough time has passed since the last scan.
  /// Use this with RE-36 double-scan prevention logic:
  /// ```dart
  /// if (!QrScannerConfig.canScan()) return; // ignore, too soon
  /// QrScannerConfig.markScanned();          // record this scan
  /// ```
  static bool canScan() {
    if (_lastScanTime == null) return true;
    return DateTime.now().difference(_lastScanTime!) >= cooldown;
  }

  /// Record that a scan just happened.
  static void markScanned() {
    _lastScanTime = DateTime.now();
  }

  /// Reset the cooldown (e.g., after dismissing the dialog).
  static void resetCooldown() {
    _lastScanTime = null;
  }
}