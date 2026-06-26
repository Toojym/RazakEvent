import 'package:razak_event/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_view.dart';
import 'auth_view.dart';
import 'verify_email_view.dart';

class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    // userChanges() streams updates not just on sign-in/out, but also when user.reload() is called!
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A0A),
            body: Center(child: CustomLoadingIndicator(color: Colors.white)),
          );
        }
        
        if (snapshot.hasData) {
          final user = snapshot.data!;
          // Route to verification screen if their email isn't verified
          if (!user.emailVerified) {
            return const VerifyEmailView();
          }
          return const MainView();
        }
        
        return const AuthView();
      },
    );
  }
}
