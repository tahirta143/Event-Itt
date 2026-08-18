import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/customer_auth_provider.dart';
import '../../utils/colors/app_colors.dart';
import '../../utils/animations/app_animations.dart';
import '../../widgets/video_bg/video_bg_widget.dart';
import '../login/login_screen.dart';

/// Customer account registration screen.
///
/// Calls POST /api/customer/auth/register and on success navigates
/// back to the LoginScreen (Customer tab, OTP step pre-filled with the email).
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;
  String? _errorMsg;
  String? _successMsg;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = 'Please fill in Name, Email, and Password.');
      return;
    }
    if (password.length < 6) {
      setState(
          () => _errorMsg = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMsg = null;
      _successMsg = null;
    });

    final customerAuth = context.read<CustomerAuthProvider>();
    final error = await customerAuth.register(
      name: name,
      email: email,
      password: password,
      phone: _phoneController.text.isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error == null) {
      setState(() =>
          _successMsg = 'Account created! Please sign in to continue.');
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        AppAnimations.fadeInRoute(const LoginScreen()),
      );
    } else {
      setState(() => _errorMsg = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoBgWidget(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Plan your dream event with EVENT ITT',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textWhite.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Glassmorphism Card ──
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Success message
                        if (_successMsg != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded,
                                    color: Colors.greenAccent, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _successMsg!,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.greenAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Error message
                        if (_errorMsg != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Colors.redAccent, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMsg!,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        _buildLabel('Full Name'),
                        _buildTextField(_nameController,
                            'Your full name', Icons.person_outline_rounded),
                        const SizedBox(height: 14),

                        _buildLabel('Email Address'),
                        _buildTextField(_emailController,
                            'wedding@example.com', Icons.email_outlined,
                            inputType: TextInputType.emailAddress),
                        const SizedBox(height: 14),

                        _buildLabel('Phone Number (optional)'),
                        _buildTextField(_phoneController,
                            '+92 300 1234567', Icons.phone_outlined,
                            inputType: TextInputType.phone),
                        const SizedBox(height: 14),

                        _buildLabel('Password'),
                        _buildTextField(
                          _passwordController,
                          '••••••••',
                          Icons.lock_outline_rounded,
                          isObscure: !_showPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.champagne,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _showPassword = !_showPassword),
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandPink,
                              foregroundColor: AppColors.textWhite,
                              disabledBackgroundColor:
                                  AppColors.brandPink.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Create Account',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                        Text(
                          'Sign In',
                          style: GoogleFonts.montserrat(
                            color: AppColors.champagne,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
      );

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isObscure = false,
    TextInputType? inputType,
    Widget? suffixIcon,
  }) =>
      TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: inputType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.champagne, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      );
}
