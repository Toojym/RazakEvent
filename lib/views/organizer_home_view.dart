import 'package:razak_event/widgets/custom_loading_indicator.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../viewmodels/home_viewmodel.dart';
import 'logo_view.dart';
import 'active_events_list_view.dart';
import 'upload_report_view.dart';
import 'view_reports_view.dart';

/// Organizer Home View
/// Displays metrics and quick actions for organizers.
/// Matches the Figma design:
/// - RazakEvent logo at the top
/// - Large "Active Events" card with a purple "View Events" button
/// - Two smaller cards: "Uploaded Reports" and "Uploaded Paperwork"
/// - "View Reports" and "Upload Report" buttons
class OrganizerHomeView extends StatelessWidget {
  const OrganizerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen background ────────────────────────────
          Positioned.fill(
            child: Container(decoration: AppTheme.backgroundDecoration3),
          ),

          // ── Content ───────────────────────────────────────────
          SafeArea(
            child: vm.isLoading
                ? const Center(
                    child:
                        CustomLoadingIndicator(color: AppTheme.primaryBlue),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header Logo ─────────────────────────────
                        const Center(child: RazakEventLogo(fontSize: 24)),
                        const SizedBox(height: 48),

                        // ── Active Events Card ──────────────────────
                        _GlassCard(
                          title: 'Active\nEvents',
                          value: '${vm.activeEventsCount}',
                          height: 160,
                        ),
                        const SizedBox(height: 12),

                        // ── View Events Button ──────────────────────
                        _ActionButton(
                          label: 'View Events',
                          color: const Color(0xFF5A149B),
                          onPressed: () {
                            final vm = context.read<HomeViewModel>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: vm,
                                  child: const ActiveEventsListView(),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // ── Reports and Paperwork Cards Row ─────────
                        Row(
                          children: [
                            Expanded(
                              child: _GlassCard(
                                title: 'Uploaded\nReports',
                                value: '${vm.uploadedReportsCount}',
                                height: 160,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _GlassCard(
                                title: 'Uploaded\nPaperwork',
                                value: '${vm.uploadedPaperworkCount}',
                                height: 160,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── View Reports Button ─────────────────────
                        _ActionButton(
                          label: 'View Reports',
                          color: const Color(0xFF0D559E),
                          onPressed: () {
                            final vm = context.read<HomeViewModel>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: vm,
                                  child: const ViewReportsView(),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        // ── Upload Report Button ────────────────────
                        _ActionButton(
                          label: 'Upload Report',
                          color: const Color(0xFF5A149B),
                          onPressed: () {
                            final vm = context.read<HomeViewModel>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: vm,
                                  child: const UploadReportView(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Glassmorphic Card ────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final String title;
  final String value;
  final double height;

  const _GlassCard({
    required this.title,
    required this.value,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    height: 1.0,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Styled Action Button ─────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
