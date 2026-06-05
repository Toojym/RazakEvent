import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../repositories/user_repository.dart';
import '../repositories/attendance_repository.dart';
import 'logo_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(
        userRepo: UserRepository(),
        attendanceRepo: AttendanceRepository(),
      ),
      child: const _ProfileViewBody(),
    );
  }
}

class _ProfileViewBody extends StatelessWidget {
  const _ProfileViewBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration2,
        child: SafeArea(
          child: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                )
              : RefreshIndicator(
                  onRefresh: vm.refresh,
                  color: AppTheme.primaryBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        children: [
                          // ── Header ──────────────────────────────────────────
                          const Center(child: RazakEventLogo(fontSize: 24)),
                          const SizedBox(height: 4),
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── Rank Section ────────────────────────────────────
                          const Text(
                            'Your Leaderboard Rank',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '#${vm.rank}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Leaderboard Button ──────────────────────────────
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Navigate to leaderboard view
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('View Leaderboard'),
                          ),
                          const SizedBox(height: 32),

                          // ── Stats Grid ──────────────────────────────────────
                          SizedBox(
                            height: 320,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left Column (Tall Card)
                                Expanded(
                                  child: _GlassCard(
                                    title: 'Merits\nCollected',
                                    value: '${vm.user?.meritPoints ?? 0}',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Right Column (Two Small Cards)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: _GlassCard(
                                          title: 'Events Participated',
                                          value: '${vm.eventsParticipated}',
                                          smallText: true,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: _GlassCard(
                                          title: 'Events\nVolunteered',
                                          value: '${vm.eventsVolunteered}',
                                          smallText: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),

                          // ── Footer ──────────────────────────────────────────
                          if (vm.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                vm.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          Text(
                            vm.isLoading
                                ? 'Loading...'
                                : (vm.user?.name.isNotEmpty == true
                                    ? vm.user!.name
                                    : 'Unknown User'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vm.isLoading
                                ? ''
                                : (vm.user?.faculty ?? 'Faculty of Computing'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// A glassmorphic card widget used in the stats grid.
class _GlassCard extends StatelessWidget {
  final String title;
  final String value;
  final bool smallText;

  const _GlassCard({
    required this.title,
    required this.value,
    this.smallText = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w300,
                  height: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: smallText ? 12 : 14,
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