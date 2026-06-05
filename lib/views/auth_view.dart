import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/app_theme.dart';

/// Auth View — Login and Sign Up screens.
/// Matches the Figma design:
///   - Dark orange/brown texture background
///   - "RazakEvent" logo above the card
///   - White rounded card with form fields
///   - Blue rounded action button
///   - "Powered by Puzl" footer
class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _formKey = GlobalKey<FormState>();
  final _matricController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _matricController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // ── Clear fields when switching between Login / Sign Up ──────────
  void _onToggleMode(AuthViewModel vm) {
    _formKey.currentState?.reset();
    _matricController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPassController.clear();
    vm.toggleLoginMode();
  }

  // ── Submit handler ───────────────────────────────────────────────
  Future<void> _submit(AuthViewModel vm) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    String? error;

    if (vm.isLogin) {
      // Login uses email directly (restricted to @graduate.utm.my)
      error = await vm.login(_emailController.text, _passwordController.text);
    } else {
      error = await vm.signUp(
        matric: _matricController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPassController.text,
      );
    }

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.isLogin ? 'Login successful!' : 'Account created!'),
          backgroundColor: Colors.green,
        ),
      );
      // RootView will handle navigation via auth state stream
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Container(
            // Background gradient — replace with your Figma texture:
            // decoration: BoxDecoration(
            //   image: DecorationImage(
            //     image: AssetImage('assets/images/bg_texture.png'),
            //     fit: BoxFit.cover,
            //   ),
            // ),
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ── Scrollable content ───────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),

                          // ── RazakEvent Logo ──────────────────
                          _buildLogo(),
                          const SizedBox(height: 40),

                          // ── White form card ──────────────────
                          _buildCard(vm),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // ── "Powered by Puzl" footer ─────────────────
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
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
        );
      },
    );
  }

  // ── Logo ─────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Razak',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          ),
          TextSpan(
            text: 'Event',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── White card ───────────────────────────────────────────────────
  Widget _buildCard(AuthViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── UTM Email (both Login and Sign Up) ───────────
            _buildField(
              controller: _emailController,
              hint: vm.isLogin ? 'UTM Email' : 'UTM Email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your UTM email';
                }
                if (!v.trim().endsWith('@graduate.utm.my')) {
                  return 'Only @graduate.utm.my emails are allowed';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── Matric / Staff No. (Sign Up only) ────────────
            if (!vm.isLogin) ...[
              _buildField(
                controller: _matricController,
                hint: 'Student Matrics / Staff No.',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter your matric / staff number'
                    : null,
              ),
              const SizedBox(height: 12),
            ],

            // ── Password ────────────────────────────────────
            _buildField(
              controller: _passwordController,
              hint: 'Password',
              obscure: _obscurePassword,
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your password';
                if (!vm.isLogin && v.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── Confirm Password (Sign Up only) ──────────────
            if (!vm.isLogin) ...[
              _buildField(
                controller: _confirmPassController,
                hint: 'Confirm Password',
                obscure: _obscureConfirmPassword,
                onToggleObscure: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 8),

            // ── Action button ────────────────────────────────
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : () => _submit(vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: vm.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        vm.isLogin ? 'Login' : 'Sign Up',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Toggle link ──────────────────────────────────
            GestureDetector(
              onTap: () => _onToggleMode(vm),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                  ),
                  children: [
                    TextSpan(
                      text: vm.isLogin
                          ? "Don't have an account? Sign up "
                          : "Have an account already? Login ",
                    ),
                    const TextSpan(
                      text: 'here!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable form field ───────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textHint,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
