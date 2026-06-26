import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/app_theme.dart';
import 'logo_view.dart';

/// Auth View — Login and Sign Up screens.
/// Matches the Figma design:
///   - Full-screen background image (assets/images/bg_texture.png)
///   - "RazakEvent" logo above the card
///   - White rounded card with form fields (vertically centred)
///   - Blue rounded action button
///   - "Powered by Puzi" footer
class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _matricController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _selectedFaculty;

  // ── All UTM faculties & schools ──────────────────────────────────
  static const List<String> _utmFaculties = [
    'Faculty of Built Environment & Surveying',
    'Faculty of Chemical & Energy Engineering',
    'Faculty of Civil Engineering',
    'Faculty of Computing',
    'Faculty of Electrical Engineering',
    'Faculty of Mechanical Engineering',
    'Faculty of Science',
    'Faculty of Social Sciences & Humanities',
    'Faculty of Educational Sciences and Technology',
    'Faculty of Management',
    'Faculty of Artificial Intelligence',
    'Azman Hashim International Business School',
    'Razak Faculty of Technology & Informatics',
    'Malaysia-Japan International Institute of Technology',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _matricController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // ── Clear fields when switching between Login / Sign Up ──────────
  void _onToggleMode(AuthViewModel vm) {
    _formKey.currentState?.reset();
    _nameController.clear();
    _matricController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPassController.clear();
    setState(() => _selectedFaculty = null);
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
        name: _nameController.text,
        matric: _matricController.text,
        faculty: _selectedFaculty ?? '',
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
          // Prevent the background from resizing when keyboard appears
          resizeToAvoidBottomInset: false,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppTheme.backgroundDecoration,
            child: SafeArea(
              child: Column(
                children: [
                  // ── Scrollable centre content ──────────────────
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── RazakEvent Logo ──────────────────
                            const RazakEventLogo(fontSize: 30),
                            const SizedBox(height: 32),

                            // ── White form card ──────────────────
                            _buildCard(vm),
                          ],
                        ),
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

  // ── White card ───────────────────────────────────────────────────
  Widget _buildCard(AuthViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
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
            // ── Full Name (Sign Up only) ────
            if (!vm.isLogin) ...[
              _buildLabeledField(
                label: 'Full Name',
                controller: _nameController,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter your full name'
                    : null,
              ),
              const SizedBox(height: 14),

              // ── Student Matrics / Staff No. (Sign Up only) ────
              _buildLabeledField(
                label: 'Student Matrics / Staff No.',
                controller: _matricController,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter your matric / staff number'
                    : null,
              ),
              const SizedBox(height: 14),

              // ── Faculty (Sign Up only) ────────────────────
              _buildFacultyDropdown(),
              const SizedBox(height: 14),
            ],

            // ── UTM Email (both modes — login uses this) ─────
            _buildLabeledField(
              label: 'UTM Email',
              controller: _emailController,
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

            // ── Password ────────────────────────────────────
            const SizedBox(height: 14),
            _buildLabeledField(
              label: 'Password',
              controller: _passwordController,
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

            // ── Confirm Password (Sign Up only) ──────────────
            if (!vm.isLogin) ...[
              const SizedBox(height: 14),
              _buildLabeledField(
                label: 'Confirm Password',
                controller: _confirmPassController,
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
            ],

            const SizedBox(height: 20),

            // ── Action button ────────────────────────────────
            Center(
              child: SizedBox(
                width: 140,
                height: 44,
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

  // ── Faculty dropdown ──────────────────────────────────────────────
  Widget _buildFacultyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Faculty / School',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedFaculty,
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textHint),
          style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
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
              borderSide:
                  const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
          hint: const Text(
            'Select your faculty',
            style: TextStyle(color: AppTheme.textHint, fontSize: 14),
          ),
          items: _utmFaculties
              .map((f) => DropdownMenuItem(
                    value: f,
                    child: Text(
                      f,
                      style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
                    ),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedFaculty = value),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Please select your faculty' : null,
        ),
      ],
    );
  }

  // ── Reusable form field with label above ──────────────────────────
  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
          decoration: InputDecoration(
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
              vertical: 12,
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
              borderSide:
                  const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
