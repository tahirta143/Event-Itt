import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Accent Color (#ea4c89)
  static const Color brandPink = Color(0xFFC43B7B
  );

  // Primary Theme Colors
  static const Color darkBackground = Color(0xFF141414);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkHeader = Color(0xFFC43B7B);
  static const Color darkCard = Color(0xFFC43B7B);


  // Accent & Luxury Colors
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color roseGold = Color(0xFFE8C39E);
  static const Color champagne = Color(0xFFF7E7CE);
  static const Color romanticPink = Color(0xFFF6D6D6);
  static const Color warmPeach = Color(0xFFFFECE4);
  static const Color softCoral = Color(0xFFEE786C);

  // Background & Surface
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF2F2F4);
  static const Color borderGrey = Color(0xFFE5E5E8);

  // Text Colors
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status & Badges
  static const Color starRating = Color(0xFFFFB800);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color discountOrange = Color(0xFFE65100);

  // Gradients
  static const LinearGradient luxuryHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0F10), Color(0xFF1C1C1E)],
  );

  static const LinearGradient promoBannerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFD4C2), Color(0xFFFFEAE0)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0xAAFFFFFF),
      Color(0xFFFFFFFF),
    ],
  );

  static const LinearGradient darkOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x33000000),
      Color(0x88000000),
      Color(0xDD000000),
    ],
  );
}
