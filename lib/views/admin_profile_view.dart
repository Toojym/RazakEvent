import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'logo_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../viewmodels/admin_profile_viewmodel.dart';

/// Admin profile page matching the design with glassmorphism stat cards,
/// custom background, and sign-out button.
class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProfileViewModel(),
      child: const _AdminProfileBody(),
    );
  }
}

class _AdminProfileBody extends StatelessWidget {
  const _AdminProfileBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminProfileViewModel>();
    // User data with fallback
    final displayName = vm.user?.name ?? 'Loading...';
    final role = 'Vice President of Activity';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(decoration: AppTheme.backgroundDecoration3),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const RazakEventLogo(fontSize: 24),
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
                  
                  // Name and Role
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Cards Grid
                  vm.isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _GlassCard(
                              title: 'Total of Events\nCurrent Session',
                              value: '${vm.totalSessionEvents}',
                              height: 316,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                _GlassCard(
                                  title: 'Total of Events\nSemester I',
                                  value: '${vm.sem1Events}',
                                  height: 150,
                                ),
                                const SizedBox(height: 16),
                                _GlassCard(
                                  title: 'Total of Events\nSemester II',
                                  value: '${vm.sem2Events}',
                                  height: 150,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  if (!vm.isLoading) const SizedBox(height: 16),
                  
                  // Bottom Card — "Number of Uploaded Letters"
                  if (!vm.isLoading)
                    _HorizontalGlassCard(
                      title: 'Number of\nUploaded Letters',
                      value: '${vm.uploadedLetters}',
                    ),
                  
                  const SizedBox(height: 48),
                  
                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA01515), // Red
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _HorizontalGlassCard extends StatelessWidget {
  final String title;
  final String value;

  const _HorizontalGlassCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
