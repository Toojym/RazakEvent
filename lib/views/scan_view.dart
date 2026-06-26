import 'package:razak_event/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../viewmodels/scan_viewmodel.dart';
import '../repositories/event_repository.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/user_repository.dart';
import 'logo_view.dart';

/// QR Scanner screen. Matches the Figma design:
/// - Logo and "Attendance Scanner" title at top.
/// - "Place the QR code within the scan area" subtitle.
/// - Full-screen camera view behind a dark overlay with a transparent rounded square cutout.
class ScanView extends StatelessWidget {
  final VoidCallback onGoHome;

  const ScanView({super.key, required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScanViewModel(
        eventRepo: EventRepository(),
        attendanceRepo: AttendanceRepository(),
        userRepo: UserRepository(),
      ),
      child: const _ScanViewBody(),
    );
  }
}

class _ScanViewBody extends StatefulWidget {
  const _ScanViewBody();

  @override
  State<_ScanViewBody> createState() => _ScanViewBodyState();
}

class _ScanViewBodyState extends State<_ScanViewBody> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  /// Local debounce to prevent rapid-fire hardware callbacks from even
  /// reaching the viewmodel.
  DateTime? _lastDetectTime;
  static const _kDetectDebounce = Duration(milliseconds: 500);

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture, ScanViewModel vm) {
    if (vm.status != ScanStatus.scanning) return;

    final now = DateTime.now();
    if (_lastDetectTime != null &&
        now.difference(_lastDetectTime!) < _kDetectDebounce) {
      return; // hardware debounce – too soon since last detection
    }
    _lastDetectTime = now;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final qrData = barcodes.first.rawValue!;
      vm.processQrCode(qrData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScanViewModel>();
    final parent = context.findAncestorWidgetOfExactType<ScanView>();

    // If success, we might want to wait a moment and then go home
    if (vm.status == ScanStatus.success) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.message ?? 'Success!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        parent?.onGoHome();
        // Reset the scanner after navigating away so it's ready next time
        vm.resumeScanning();
      });
    } else if (vm.status == ScanStatus.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.message ?? 'Error occurred.'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: vm.resumeScanning,
            ),
          ),
        );
      });
    }

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Stack(
          children: [
            // ── Camera View ──────────────────────────────────
            MobileScanner(
              controller: _scannerController,
              onDetect: (capture) => _onDetect(capture, vm),
            ),

            // ── Custom Dark Overlay with Cutout ──────────────
            const _ScannerOverlay(),

            // ── Header & Title (Top) ─────────────────────────
            const SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 24),
                  Center(child: RazakEventLogo(fontSize: 24)),
                  SizedBox(height: 4),
                  Text(
                    'Attendance Scanner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws a semi-transparent dark overlay with a rounded transparent square in the middle,
/// and draws a perfectly aligned white border on top of it.
class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScanViewModel>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = constraints.maxWidth * 0.75;
        // This is the alignment for both the cutout and the border
        const alignment = Alignment(0.0, 0.2);

        return Stack(
          children: [
            // 1. Dark overlay with a transparent hole
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.6),
                BlendMode.srcOut,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Align(
                  alignment: alignment,
                  child: Container(
                    width: boxSize,
                    height: boxSize,
                    decoration: BoxDecoration(
                      color: Colors.black, // This part punches the transparent hole
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),

            // 2. White border exactly on top of the hole
            Align(
              alignment: alignment,
              child: Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: vm.status == ScanStatus.processing
                    ? const Center(
                        child: CustomLoadingIndicator(
                          color: AppTheme.primaryBlue,
                        ),
                      )
                    : null,
              ),
            ),

            // 3. Instruction text positioned just above the box
            Align(
              alignment: alignment,
              child: Transform.translate(
                offset: Offset(0, -(boxSize / 2) - 60),
                child: const Text(
                  'Place the QR code within the scan area.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
