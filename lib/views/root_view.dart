import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_view.dart';
import 'auth_view.dart';

class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has user data, then they're already logged in.
        if (snapshot.hasData) {
          return const HomeView();
        }
        // Otherwise, they're not logged in.
        return const AuthView();
      },
    );
  }
}
