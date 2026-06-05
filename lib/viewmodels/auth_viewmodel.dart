import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  bool _isLogin = true;
  bool _isLoading = false;

  bool get isLogin => _isLogin;
  bool get isLoading => _isLoading;

  void toggleLoginMode() {
    _isLogin = !_isLogin;
    notifyListeners();
  }

  // ── Validate UTM student email ────────────────────────────────────
  String? _validateUTMEmail(String email) {
    if (email.trim().isEmpty) return 'Please enter your UTM email.';
    if (!email.trim().endsWith('@graduate.utm.my')) {
      return 'Only @graduate.utm.my emails are allowed.';
    }
    return null;
  }

  // ── LOGIN ─────────────────────────────────────────────────────────
  Future<String?> login(String email, String password) async {
    final emailError = _validateUTMEmail(email);
    if (emailError != null) return emailError;
    if (password.trim().isEmpty) return 'Please enter your password.';

    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'Login failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── SIGN UP ───────────────────────────────────────────────────────
  Future<String?> signUp({
    required String name,
    required String matric,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    
    if (matric.trim().isEmpty) {
      return 'Please enter your matric / staff number.';
    }

    final emailError = _validateUTMEmail(email);
    if (emailError != null) return emailError;

    if (password.isEmpty) return 'Please enter a password.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    if (password != confirmPassword) return 'Passwords do not match.';

    _isLoading = true;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      if (credential.user != null) {
        await _userRepository.createUser(
          UserModel(
            uid: credential.user!.uid,
            name: name.trim(),
            matric: matric.trim().toUpperCase(),
            kolej: 'Kolej Tun Razak',
            faculty: 'Faculty of Computing',
            meritPoints: 0,
            role: 'student',
            email: email.trim(),
          ),
        );
        // Send the verification link
        await credential.user!.sendEmailVerification();
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'Registration failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── FORGOT PASSWORD ───────────────────────────────────────────────
  Future<String?> resetPassword(String email) async {
    final emailError = _validateUTMEmail(email);
    if (emailError != null) return emailError;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No account found with that email.';
      }
      return 'Failed to send reset email.';
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
