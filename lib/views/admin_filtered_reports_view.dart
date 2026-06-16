import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/report_model.dart';
import '../utils/app_theme.dart';
import '../viewmodels/admin_filtered_reports_viewmodel.dart';
import 'logo_view.dart';

class AdminFilteredReportsView extends StatelessWidget {
  final String reportType;

  const AdminFilteredReportsView({super.key, required this.reportType});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminFilteredReportsViewModel(reportType: reportType),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminFilteredReportsViewModel>();
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
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // ── Logo & subtitle ──
                const SizedBox(height: 4),
                const Center(child: RazakEventLogo(fontSize: 24)),
                const SizedBox(height: 32),
                Text(
                  '${vm.reportType} Reports',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Reports list ──
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                        )
                      : reports.isEmpty
                          ? Center(
                              child: Text(
                                'No ${vm.reportType.toLowerCase()} reports found.',
                                style: const TextStyle(color: Colors.white54, fontSize: 14),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              itemCount: reports.length,
                              separatorBuilder: (_, _) => const Divider(
                                color: Colors.white24,
                                height: 1,
                                thickness: 0.5,
                              ),
                              itemBuilder: (context, index) {
                                final item = reports[index];
                                return _FilteredReportRow(item: item);
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
class _FilteredReportRow extends StatelessWidget {
  final ReportWithEvent item;
  const _FilteredReportRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final report = item.report;
    final dateStr = DateFormat('d/M/yyyy').format(report.uploadedAt);
    final displayName = report.fileName ?? '${report.type} Report';

    return InkWell(
      onTap: () => _openReport(context, report),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // File icon
            const Icon(Icons.description_outlined, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            // Report info
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
                    'Event: ${item.event.title}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Uploaded $dateStr',
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D559E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.open_in_new, color: Colors.white, size: 16),
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
