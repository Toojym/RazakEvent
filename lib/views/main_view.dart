import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../repositories/event_repository.dart';
import '../viewmodels/chat_assistant_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import 'home_view.dart';
import 'organizer_home_view.dart';
import 'scan_view.dart';
import 'create_event_view.dart';
import 'profile_view.dart';
import 'organizer_profile_view.dart';
import 'admin_main_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

/// MainView — shell that holds the bottom navigation bar.
/// All three tabs (Home, Scan, Profile) live inside here.
class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;
  UserModel? _user;
  bool _isLoadingUser = true;

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
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await UserRepository().getUser(uid);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoadingUser = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // Admin users get their own dedicated shell
    if (_user?.isAdmin ?? false) {
      return const AdminMainView();
    }

    final bool isOrganizer = _user?.isOrganizer ?? false;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel(EventRepository())),
        ChangeNotifierProvider(create: (_) => ChatAssistantViewModel()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        extendBody: true, // lets content slide under the nav bar
        body: IndexedStack(
          // IndexedStack keeps all tabs alive (preserves scroll position)
          index: _currentIndex,
          children: [
            isOrganizer ? const OrganizerHomeView() : const HomeView(),
            isOrganizer 
                ? const CreateEventView() 
                : ScanView(onGoHome: () => setState(() => _currentIndex = 0)),
            isOrganizer ? const OrganizerProfileView() : const ProfileView(),
          ],
        ),
        bottomNavigationBar: _BottomNavBar(
          currentIndex: _currentIndex,
          isOrganizer: isOrganizer,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex, 
    required this.isOrganizer,
    required this.onTap,
  });

  final int currentIndex;
  final bool isOrganizer;
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: isOrganizer ? const Icon(Icons.add) : const Icon(Icons.qr_code_scanner_outlined),
            activeIcon: isOrganizer ? const Icon(Icons.add_circle) : const Icon(Icons.qr_code_scanner),
            label: isOrganizer ? 'Add Event' : 'Scan',
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
