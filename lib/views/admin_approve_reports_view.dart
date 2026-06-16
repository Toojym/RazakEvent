import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_model.dart';
import '../models/report_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/admin_approve_reports_viewmodel.dart';
import 'logo_view.dart';

/// Admin page that lists all paperwork for a past event and lets the admin
/// approve or deny each report.
class AdminApproveReportsView extends StatelessWidget {
  final EventModel event;

  const AdminApproveReportsView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminApproveReportsViewModel(event: event),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminApproveReportsViewModel>();
    final reports = vm.reports;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background ──────────────────────────────────────
          Positioned.fill(
            child: Container(decoration: AppTheme.backgroundDecoration4),
          ),

          // ── Content ─────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: const Text(
                      'Past Events',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                // ── Logo & subtitle ──
                const SizedBox(height: 8),
                const Center(child: RazakEventLogo(fontSize: 24)),
                const SizedBox(height: 4),
                const Text(
                  'Approve Paperwork',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Event title ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    vm.event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${reports.length} Report${reports.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Divider ──
                const Divider(color: Colors.white24, height: 1, thickness: 1),

                // ── Reports list ──
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryBlue),
                        )
                      : reports.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'No paperwork has been uploaded for this event.',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 0),
                              itemCount: reports.length,
                              separatorBuilder: (_, _) => const Divider(
                                color: Colors.white24,
                                height: 1,
                                thickness: 0.5,
                              ),
                              itemBuilder: (context, index) {
                                final report = reports[index];
                                return _ApprovalRow(report: report);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single report row with approve / deny ───────────────────────────────
class _ApprovalRow extends StatelessWidget {
  final ReportModel report;
  const _ApprovalRow({required this.report});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d/M/yyyy').format(report.uploadedAt);
    final displayName = report.fileName ?? '${report.type} Report';

    // Status badge colours
    Color statusColor;
    IconData statusIcon;
    String statusLabel;
    switch (report.approvalStatus) {
      case 'approved':
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle;
        statusLabel = 'Approved';
        break;
      case 'denied':
        statusColor = const Color(0xFFE57373);
        statusIcon = Icons.cancel;
        statusLabel = 'Denied';
        break;
      default:
        statusColor = const Color(0xFFFFB74D);
        statusIcon = Icons.hourglass_empty;
        statusLabel = 'Pending';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // ── Top row: file info + status ──
          Row(
            children: [
              const Icon(Icons.description_outlined,
                  color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${report.type} • Uploaded $dateStr',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Bottom row: action buttons ──
          Row(
            children: [
              const SizedBox(width: 32), // align with text above

              // View file button
              Expanded(
                child: _ActionButton(
                  icon: Icons.open_in_new,
                  label: 'View File',
                  color: const Color(0xFF0D559E),
                  onTap: () => _openReport(context, report),
                ),
              ),
              const SizedBox(width: 8),

              // Approve button
              Expanded(
                child: _ActionButton(
                  icon: Icons.check_circle_outline,
                  label: 'Approve',
                  color: report.approvalStatus == 'approved'
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF4CAF50),
                  onTap: report.approvalStatus == 'approved'
                      ? null
                      : () => _updateStatus(context, report.reportId, 'approved'),
                ),
              ),
              const SizedBox(width: 8),

              // Deny button
              Expanded(
                child: _ActionButton(
                  icon: Icons.cancel_outlined,
                  label: 'Deny',
                  color: report.approvalStatus == 'denied'
                      ? const Color(0xFFC62828)
                      : const Color(0xFFE57373),
                  onTap: report.approvalStatus == 'denied'
                      ? null
                      : () => _updateStatus(context, report.reportId, 'denied'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateStatus(BuildContext context, String reportId, String status) {
    final vm =
        Provider.of<AdminApproveReportsViewModel>(context, listen: false);
    vm.updateStatus(reportId, status);

    final label = status == 'approved' ? 'approved' : 'denied';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report $label successfully.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openReport(BuildContext context, ReportModel report) async {
    final url = report.fileUrl;
    if (url == null || url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file available for this report.')),
        );
      }
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the report file.')),
        );
      }
    }
  }
}

// ── Reusable compact action button ──────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
