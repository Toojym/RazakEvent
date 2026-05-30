import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/scan_result.dart';

class ScanResultDialog extends StatefulWidget {
  final ScanResult result;
  final int autoDismissSeconds;
  final VoidCallback? onDismiss;

  const ScanResultDialog({
    super.key,
    required this.result,
    this.autoDismissSeconds = 3,
    this.onDismiss,
  });

  @override
  State<ScanResultDialog> createState() => _ScanResultDialogState();
}

class _ScanResultDialogState extends State<ScanResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeIn,
    );
    _scaleController.forward();

    switch (widget.result.type) {
      case ScanResultType.success:
        HapticFeedback.heavyImpact();
        break;
      case ScanResultType.alreadyScanned:
        HapticFeedback.mediumImpact();
        break;
      default:
        HapticFeedback.lightImpact();
    }

    if (widget.result.type == ScanResultType.success) {
      Future.delayed(
        Duration(seconds: widget.autoDismissSeconds),
        _dismiss,
      );
    }
  }

  void _dismiss() {
    if (!mounted) return;
    _scaleController.reverse().then((_) {
      if (!mounted) return;
      widget.onDismiss?.call();
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  _DialogConfig get _config {
    switch (widget.result.type) {
      case ScanResultType.success:
        return _DialogConfig(
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green,
          iconBg: Colors.green.withOpacity(0.15),
          title: 'Checked In!',
          message: widget.result.eventName ?? 'Event',
          autoDismiss: true,
        );
      case ScanResultType.alreadyScanned:
        return _DialogConfig(
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.amber,
          iconBg: Colors.amber.withOpacity(0.15),
          title: 'Already Checked In',
          message:
              'You have already scanned for ${widget.result.eventName ?? 'this event'}.',
          autoDismiss: false,
          buttonText: 'OK',
        );
      case ScanResultType.invalidQr:
        return _DialogConfig(
          icon: Icons.qr_code_2_rounded,
          iconColor: Colors.redAccent,
          iconBg: Colors.redAccent.withOpacity(0.15),
          title: 'Invalid QR Code',
          message: 'This QR code does not match any active event.',
          autoDismiss: false,
          buttonText: 'OK',
        );
      case ScanResultType.networkError:
        return _DialogConfig(
          icon: Icons.wifi_off_rounded,
          iconColor: Colors.redAccent,
          iconBg: Colors.redAccent.withOpacity(0.15),
          title: 'Connection Error',
          message:
              widget.result.errorMessage ??
              'Could not record attendance. Please try again.',
          autoDismiss: false,
          buttonText: 'Retry',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final r = widget.result;

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: config.iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      config.icon,
                      size: 48,
                      color: config.iconColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    config.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    config.message,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (r.type == ScanResultType.success) ...[
                    const SizedBox(height: 16),
                    _buildSuccessDetail(r),
                  ],
                  const SizedBox(height: 24),
                  if (!config.autoDismiss)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _dismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: config.iconColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          config.buttonText ?? 'OK',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (config.autoDismiss)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 0.0),
                      duration: Duration(seconds: widget.autoDismissSeconds),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value.clamp(0.3, 1.0),
                          child: Text(
                            'Dismissing in ${value.ceil()}...',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessDetail(ScanResult r) {
    final timeStr = r.scannedAt != null
        ? '${r.scannedAt!.hour.toString().padLeft(2, '0')}:'
            '${r.scannedAt!.minute.toString().padLeft(2, '0')}:'
            '${r.scannedAt!.second.toString().padLeft(2, '0')}'
        : 'just now';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _detailRow(Icons.person_rounded, r.userName ?? 'User'),
          const SizedBox(height: 6),
          _detailRow(Icons.star_rounded, '+${r.pointsAwarded ?? 1} Merit Point${(r.pointsAwarded ?? 1) == 1 ? '' : 's'}',
              valueColor: Colors.amber),
          const SizedBox(height: 6),
          _detailRow(Icons.badge_rounded,
              (r.joinRole ?? 'attendee').capitalize()),
          const SizedBox(height: 6),
          _detailRow(Icons.schedule_rounded, timeStr),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: valueColor ?? Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _DialogConfig {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String message;
  final bool autoDismiss;
  final String? buttonText;

  const _DialogConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.message,
    required this.autoDismiss,
    this.buttonText,
  });
}

extension _StringCap on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}