import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../widgets/scan_result_dialog.dart';

class ScanResultDemoView extends StatelessWidget {
  const ScanResultDemoView({super.key});

  void _showResult(BuildContext context, ScanResult result) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      pageBuilder: (_, __, ___) => ScanResultDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          'RE-39 Dialog Demo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tap each button to preview the scan result dialogs.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 30),
            _demoButton(
              context: context,
              label: 'Success — Checked In',
              color: Colors.green,
              icon: Icons.check_circle_rounded,
              onTap: () => _showResult(
                context,
                ScanResult(
                  type: ScanResultType.success,
                  userName: 'Ahmad Razak',
                  eventName: 'Karnival Sukan Kolej',
                  pointsAwarded: 3,
                  joinRole: 'crew',
                  scannedAt: DateTime.now(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _demoButton(
              context: context,
              label: 'Error — Already Scanned',
              color: Colors.amber,
              icon: Icons.warning_amber_rounded,
              onTap: () => _showResult(
                context,
                ScanResult(
                  type: ScanResultType.alreadyScanned,
                  userName: 'Ahmad Razak',
                  eventName: 'Karnival Sukan Kolej',
                ),
              ),
            ),
            const SizedBox(height: 16),
            _demoButton(
              context: context,
              label: 'Error — Invalid QR Code',
              color: Colors.redAccent,
              icon: Icons.qr_code_2_rounded,
              onTap: () => _showResult(
                context,
                const ScanResult(type: ScanResultType.invalidQr),
              ),
            ),
            const SizedBox(height: 16),
            _demoButton(
              context: context,
              label: 'Error — Network / Connection',
              color: Colors.redAccent,
              icon: Icons.wifi_off_rounded,
              onTap: () => _showResult(
                context,
                const ScanResult(
                  type: ScanResultType.networkError,
                  errorMessage:
                      'Could not reach Firebase. Check your connection.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _demoButton({
    required BuildContext context,
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: Colors.white,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}