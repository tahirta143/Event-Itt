import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors/app_colors.dart';

class CustomHeaderWidget extends StatelessWidget {
  final VoidCallback onDrawerTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onLocationTap;

  const CustomHeaderWidget({
    super.key,
    required this.onDrawerTap,
    required this.onNotificationTap,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: topPadding + 8,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.darkHeader,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Drawer menu & Venue Vibe Logo
            Row(
              children: [
                IconButton(
                  onPressed: onDrawerTap,
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.textWhite,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 4),
                // Venue Vibe Monogram + Text Logo (Exact match with Image 2)
                Row(
                  children: [
                    Stack(
                      children: [
                        Text(
                          'EI',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                            letterSpacing: -2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'EVENT',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'ITT',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              ],
            ),

            // Right Action Buttons: Location Pin & Notification Bell inside circular dark containers
            Row(
              children: [
                GestureDetector(
                  onTap: onLocationTap,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textWhite,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onNotificationTap,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textWhite,
                          size: 20,
                        ),
                        Positioned(
                          top: 10,
                          right: 11,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.softCoral,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

