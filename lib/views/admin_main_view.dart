import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../repositories/event_repository.dart';
import '../viewmodels/admin_home_viewmodel.dart';
import 'admin_home_view.dart';
import 'admin_profile_view.dart';

/// AdminMainView — shell that holds the bottom navigation bar for admin users.
/// Three tabs: Home, Upload (placeholder), Profile.
class AdminMainView extends StatefulWidget {
  const AdminMainView({super.key});

  @override
  State<AdminMainView> createState() => _AdminMainViewState();
}

class _AdminMainViewState extends State<AdminMainView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Light status bar icons to show over the dark home background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminHomeViewModel(EventRepository()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        extendBody: true, // lets content slide under the nav bar
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: Admin Home
            const AdminHomeView(),

            // Tab 1: Upload placeholder (does nothing)
            const _UploadPlaceholder(),

            // Tab 2: Admin Profile
            const AdminProfileView(),
          ],
        ),
        bottomNavigationBar: _AdminBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

// ── Upload Placeholder ─────────────────────────────────────────────────
/// Empty placeholder tab for the Upload button (does nothing for now).
class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: SizedBox.shrink(),
    );
  }
}

// ── Bottom Navigation Bar ──────────────────────────────────────────────
class _AdminBottomNavBar extends StatelessWidget {
  const _AdminBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_outlined),
            activeIcon: Icon(Icons.upload),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
