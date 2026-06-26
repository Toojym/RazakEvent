import 'package:razak_event/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_model.dart';
import '../models/report_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/admin_event_reports_viewmodel.dart';
import 'logo_view.dart';

/// Admin page that lists all paperwork / reports uploaded for a specific event.
/// Tapping a report row opens the uploaded file in the browser / external viewer.
class AdminEventReportsView extends StatelessWidget {
  final EventModel event;

  const AdminEventReportsView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminEventReportsViewModel(event: event),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminEventReportsViewModel>();
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
                      'Active Events',
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
                  'Event Paperwork',
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
                  '${reports.length} Report${reports.length == 1 ? '' : 's'} Uploaded',
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
                          child: CustomLoadingIndicator(
                              color: AppTheme.primaryBlue),
                        )
                      : reports.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'No paperwork has been uploaded for this event yet.',
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
                                return _ReportRow(report: report);
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

// ── Single report row ───────────────────────────────────────────────────
class _ReportRow extends StatelessWidget {
  final ReportModel report;
  const _ReportRow({required this.report});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d/M/yyyy').format(report.uploadedAt);
    final displayName = report.fileName ?? '${report.type} Report';

    return InkWell(
      onTap: () => _openReport(context, report),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // File icon
            const Icon(Icons.description_outlined,
                color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            // Report name & type
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
            // Open button
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D559E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.open_in_new,
                  color: Colors.white, size: 16),
            ),
          ],
        ),
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
