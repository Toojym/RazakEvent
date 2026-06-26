import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../models/user_model.dart';
import '../viewmodels/leaderboard_viewmodel.dart';
import '../repositories/user_repository.dart';
import 'logo_view.dart';

/// Merits Leaderboard screen.
///
/// Layout (matching the Figma design):
/// - RazakEvent logo + "My Profile" subtitle at top
/// - "Merits Leaderboard" section title
/// - Podium: #1 centred on top, #2 left, #3 right (glassmorphic cards)
/// - Scrollable list of ranks #4–#10 with dividers
/// - Current user row highlighted with a blue background bar
class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeaderboardViewModel(UserRepository()),
      child: const _LeaderboardBody(),
    );
  }
}

class _LeaderboardBody extends StatelessWidget {
  const _LeaderboardBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeaderboardViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen background ────────────────────────────
          Positioned.fill(
            child: Container(decoration: AppTheme.backgroundDecoration2),
          ),

          // ── Gradient overlay to darken the lower portion ──────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    const Color(0xFF0D0400).withValues(alpha: 0.75),
                    const Color(0xFF0D0400),
                  ],
                  stops: const [0.0, 0.40, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: _buildContent(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(LeaderboardViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Text(
          vm.errorMessage!,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // ── Header ──────────────────────────────────────
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
          const SizedBox(height: 28),

          // ── Section Title ─────────────────────────────────
          const Text(
            'Merits Leaderboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),

          // ── Podium ──────────────────────────────────────────
          _buildPodium(vm),
          const SizedBox(height: 28),

          // ── Remaining list (#4–#10) ─────────────────────────
          if (vm.remainingUsers.isNotEmpty) _buildRemainingList(vm),
        ],
      ),
    );
  }

  // ── Podium: #1 top-centre, #2 bottom-left, #3 bottom-right ────
  Widget _buildPodium(LeaderboardViewModel vm) {
    final podium = vm.podiumUsers;

    if (podium.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No users yet.',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final first = podium.isNotEmpty ? podium[0] : null;
    final second = podium.length > 1 ? podium[1] : null;
    final third = podium.length > 2 ? podium[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // ── #1 card (centred, tallest) ─────────────────────
          if (first != null)
            _PodiumCard(
              rank: 1,
              user: first,
              isCurrentUser: first.uid == vm.currentUid,
            ),
          const SizedBox(height: 12),

          // ── #2 and #3 side by side ────────────────────────
          Row(
            children: [
              if (second != null)
                Expanded(
                  child: _PodiumCard(
                    rank: 2,
                    user: second,
                    isCurrentUser: second.uid == vm.currentUid,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              const SizedBox(width: 12),
              if (third != null)
                Expanded(
                  child: _PodiumCard(
                    rank: 3,
                    user: third,
                    isCurrentUser: third.uid == vm.currentUid,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  // ── List of ranks #4+ ──────────────────────────────────────────
  Widget _buildRemainingList(LeaderboardViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: List.generate(vm.remainingUsers.length, (i) {
          final user = vm.remainingUsers[i];
          final rank = i + 4; // starts at #4
          final isCurrentUser = user.uid == vm.currentUid;

          return Column(
            children: [
              // ── Divider ──────────────────────────────────────
              Divider(
                color: Colors.white.withValues(alpha: 0.12),
                height: 1,
              ),

              // ── Row (with highlight bar for current user) ────
              Container(
                decoration: isCurrentUser
                    ? BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(6),
                      )
                    : null,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    // Rank number
                    SizedBox(
                      width: 48,
                      child: Text(
                        '# $rank',
                        style: TextStyle(
                          color: isCurrentUser
                              ? Colors.white
                              : Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // User name
                    Expanded(
                      child: Text(
                        user.name.isNotEmpty ? user.name : 'Unknown',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: isCurrentUser
                              ? Colors.white
                              : Colors.white60,
                          fontSize: 13,
                          fontWeight: isCurrentUser
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Glassmorphic Podium Card ─────────────────────────────────────────
class _PodiumCard extends StatelessWidget {
  final int rank;
  final UserModel user;
  final bool isCurrentUser;

  const _PodiumCard({
    required this.rank,
    required this.user,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;
    final cardHeight = isFirst ? 150.0 : 130.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            color: isCurrentUser
                ? AppTheme.primaryBlue.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentUser
                  ? AppTheme.primaryBlue.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rank number
                Text(
                  '#$rank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isFirst ? 52 : 40,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),

                // User name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    user.name.isNotEmpty ? user.name : 'Unknown',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: isFirst ? 14 : 12,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
