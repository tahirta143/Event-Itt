import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors/app_colors.dart';

class HeroBannerWidget extends StatelessWidget {
  final VoidCallback onExploreTap;

  const HeroBannerWidget({
    super.key,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightGrey, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left Content Text + Button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Text(
                    'Your Dream\nVenue Awaits',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: onExploreTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPink,
                    foregroundColor: AppColors.textWhite,
                    elevation: 2,
                    shadowColor: AppColors.brandPink.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Explore',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right Cutout Image with Dome/Arch Shape matching Image 2
          Positioned(
            right: 12,
            top: 12,
            bottom: 12,
            width: 145,
            child: ClipPath(
              clipper: _ArchedCutoutClipper(),
              child: Image.network(
                'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&q=80&w=800',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.brandPink,
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}

// Custom Clipper for the arched top-left cutout image shape seen in Image 2 banner
class _ArchedCutoutClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double radius = 45.0;

    path.moveTo(radius, 0);
    path.arcToPoint(
      Offset(0, radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(0, size.height - 16);
    path.quadraticBezierTo(0, size.height, 16, size.height);
    path.lineTo(size.width - 16, size.height);
    path.quadraticBezierTo(size.width, size.height, size.width, size.height - 16);
    path.lineTo(size.width, 16);
    path.quadraticBezierTo(size.width, 0, size.width - 16, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
