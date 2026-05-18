import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLogin = true;
  bool _isLoading = false;

  bool get isLogin => _isLogin;
  bool get isLoading => _isLoading;

  void toggleLoginMode() {
    _isLogin = !_isLogin;
    notifyListeners();
  }

  Future<String?> authenticate(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    String? errorMessage;

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Wrong password.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Email already in use.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password is too weak.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address.";
      } else {
        errorMessage = "Authentication failed.";
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return errorMessage; // null means success
  }

  Future<String?> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      return "Enter your email first to reset password.";
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No user found with that email.";
      } else if (e.code == 'invalid-email') {
        return "Invalid email address.";
      }
      return "Failed to send reset email.";
    }
  }
}
