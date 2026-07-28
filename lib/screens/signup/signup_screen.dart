import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/colors/app_colors.dart';
import '../../utils/animations/app_animations.dart';
import '../../widgets/video_bg/video_bg_widget.dart';
import '../home/home_screen.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoBgWidget(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                    'Plan your dream wedding with EVENT ITT',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textWhite.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Glassmorphism Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Full Name'),
                        _buildTextField(_nameController, 'Sophia & Alexander', Icons.person_outline_rounded),
                        const SizedBox(height: 14),

                        _buildLabel('Email Address'),
                        _buildTextField(_emailController, 'wedding@example.com', Icons.email_outlined),
                        const SizedBox(height: 14),

                        _buildLabel('Phone Number'),
                        _buildTextField(_phoneController, '+1 (555) 019-2834', Icons.phone_outlined),
                        const SizedBox(height: 14),

                        _buildLabel('Password'),
                        _buildTextField(_passwordController, '••••••••', Icons.lock_outline_rounded, isObscure: true),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              final auth = Provider.of<AuthProvider>(context, listen: false);
                              auth.signUp(
                                _nameController.text.isEmpty ? 'Sophia & Alexander' : _nameController.text,
                                _emailController.text,
                                _passwordController.text,
                              );
                              Navigator.of(context).pushReplacement(
                                AppAnimations.fadeInRoute(const HomeScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandPink,
                              foregroundColor: AppColors.textWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),

                            child: Text(
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
                        Text('Already have an account? ', style: GoogleFonts.inter(color: Colors.white70)),
                        Text('Sign In', style: GoogleFonts.montserrat(color: AppColors.champagne, fontWeight: FontWeight.bold)),
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

  Widget _buildLabel(String label) {
    return Padding(
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
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.champagne, size: 20),
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
}
