import 'package:razak_event/widgets/custom_loading_indicator.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../viewmodels/admin_home_viewmodel.dart';
import 'admin_active_events_view.dart';
import 'admin_all_paperwork_view.dart';
import 'admin_past_events_view.dart';
import 'logo_view.dart';

/// Admin Home View
/// Displays system-wide metrics and quick actions for admin users.
/// Design:
/// - "RazakEvent" logo at the top
/// - Large "Active Events" glassmorphic card with count
/// - Gold/amber "View Events" button
/// - Single card: "Uploaded Paperwork" with badge
/// - Red action button: "View Paperworks"
class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminHomeViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen background ────────────────────────────
          Positioned.fill(
            child: Container(decoration: AppTheme.backgroundDecoration4),
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

                        // ── View Events Button (gold/amber) ─────────
                        _GradientActionButton(
                          label: 'View Events',
                          gradientColors: const [
                            Color(0xFFB8860B),
                            Color(0xFFDAA520),
                          ],
                          onPressed: () => _showEventsChoice(context),
                        ),
                        const SizedBox(height: 24),

                        // ── Uploaded Paperwork Card (full width) ────
                        _BadgedGlassCard(
                          title: 'Uploaded\nPaperwork',
                          value: '${vm.uploadedPaperworkCount}',
                          badgeCount: vm.uploadedPaperworkCount,
                          height: 160,
                        ),
                        const SizedBox(height: 12),

                        // ── View Paperworks Button ──────────────────
                        _ActionButton(
                          label: 'View Paperworks',
                          color: const Color(0xFFC62828),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminAllPaperworkView(),
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

  // ── Bottom-sheet choice: Active vs Past events ──────────────────────
  void _showEventsChoice(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'View Events',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            // Active events option
            _ChoiceButton(
              label: 'View Active Events',
              subtitle: 'Currently running or upcoming',
              icon: Icons.event_available,
              onTap: () {
                Navigator.pop(context); // close sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminActiveEventsView(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Past events option
            _ChoiceButton(
              label: 'View Past Events',
              subtitle: 'Events that have already finished',
              icon: Icons.history,
              onTap: () {
                Navigator.pop(context); // close sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminPastEventsView(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Choice button used inside the bottom sheet ──────────────────────────
class _ChoiceButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.subtitle,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
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

// ── Glassmorphic Card with Red Badge ─────────────────────────────────
class _BadgedGlassCard extends StatelessWidget {
  final String title;
  final String value;
  final int badgeCount;
  final double height;

  const _BadgedGlassCard({
    required this.title,
    required this.value,
    required this.badgeCount,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _GlassCard(
          title: title,
          value: value,
          height: height,
        ),
        // ── Red notification badge ──────────────────────
        if (badgeCount > 0)
          Positioned(
            top: -8,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
              child: Center(
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Gradient Action Button ───────────────────────────────────────────
class _GradientActionButton extends StatelessWidget {
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const _GradientActionButton({
    required this.label,
    required this.gradientColors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
