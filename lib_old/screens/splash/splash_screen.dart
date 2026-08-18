import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors/app_colors.dart';
import '../../utils/animations/app_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/admin_auth_provider.dart';
import '../../providers/auth/vendor_auth_provider.dart';
import '../../providers/auth/customer_auth_provider.dart';
import '../admin/admin_home_screen.dart';
import '../vendor/vendor_home_screen.dart';
import '../customer/customer_home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    final startTime = DateTime.now();

    try {
      final auth = context.read<AuthProvider>();
      final adminAuth = context.read<AdminAuthProvider>();
      final vendorAuth = context.read<VendorAuthProvider>();
      final customerAuth = context.read<CustomerAuthProvider>();

      await auth.initializeRole(
        adminAuth: adminAuth,
        vendorAuth: vendorAuth,
        customerAuth: customerAuth,
      );
    } catch (e) {
      debugPrint('⚠️ [SPLASH] Error restoring auth session: $e');
    }

    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    const minSplashDuration = 2200;
    if (elapsed < minSplashDuration) {
      await Future.delayed(Duration(milliseconds: minSplashDuration - elapsed));
    }

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    Widget nextScreen;
    if (auth.currentRole == UserRole.admin) {
      nextScreen = const AdminHomeScreen();
    } else if (auth.currentRole == UserRole.vendor) {
      nextScreen = const VendorHomeScreen();
    } else if (auth.currentRole == UserRole.customer) {
      nextScreen = const CustomerHomeScreen();
    } else {
      nextScreen = const OnboardingScreen();
    }

    Navigator.of(context).pushReplacement(
      AppAnimations.fadeInRoute(nextScreen),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image from assets/videos/splash.jpg
            Positioned.fill(
              child: Image.asset(
                'assets/videos/splash.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.darkBackground,
                ),
              ),
            ),

            // Dark Luxury Vignette Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.65),
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),

            // Central Venue Vibe Monogram & Logo
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // VV Stylish Monogram Logo
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            'EI',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 84,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                              letterSpacing: -8,
                              height: 0.9,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'EVENT',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                          letterSpacing: 1.2,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'ITT',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                          letterSpacing: 1.2,
                          height: 1.0,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


