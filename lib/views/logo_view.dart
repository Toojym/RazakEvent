import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'auth_view.dart';
import 'root_view.dart';

/// Logo Screen — shown for 2.5 seconds on app launch.
/// Matches the Figma "Logo Screen" design:
///   - Dark orange/brown texture background
///   - "RazakEvent" centred logo
///   - "Powered by Puzl" footer
class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Make the status bar transparent over the dark background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Fade-in animation for the logo
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    // Navigate to RootView after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:     (_, __, ___) => const RootView(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background gradient approximating the Figma texture.
        // Replace with Image.asset('assets/images/bg_texture.png')
        // if you export the texture from Figma.
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // ── Logo — centred vertically ──────────────────
                const Expanded(child: Center(child: _RazakEventLogo())),

                // ── "Powered by Puzl" footer ───────────────────
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Powered by Puzl',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      letterSpacing: 0.5,
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

// ── Shared logo widget — used on all three screens ─────────────────────────
class _RazakEventLogo extends StatelessWidget {
  const _RazakEventLogo({this.fontSize = 32});
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Razak',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w300, // thin weight for "Razak"
              letterSpacing: 0.5,
            ),
          ),
          TextSpan(
            text: 'Event',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold, // bold for "Event"
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
