import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'admin_filtered_reports_view.dart';
import 'logo_view.dart';

class AdminReportFilterView extends StatelessWidget {
  const AdminReportFilterView({super.key});

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Select Report Type',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 48),

                // ── Buttons ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FilterButton(
                        label: 'Financial Reports',
                        icon: Icons.attach_money,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminFilteredReportsView(reportType: 'Financial'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _FilterButton(
                        label: 'Program Reports',
                        icon: Icons.event_note,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminFilteredReportsView(reportType: 'Program'),
                            ),
                          );
                        },
                      ),
                    ],
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

class _FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D559E).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white38,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
