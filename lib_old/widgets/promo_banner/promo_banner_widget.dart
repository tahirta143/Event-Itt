import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PromoBannerWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const PromoBannerWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Warm peach-pink background color matching user reference image
    const bannerBgColor = Color(0xFFC43B7B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        height: 135,
        decoration: BoxDecoration(
          color: bannerBgColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: bannerBgColor.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // 1. Right Side Image of Bride/Wedding filling ~62% of banner
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * 0.62,
                child: Image.network(
                  'https://images.unsplash.com/photo-1583939003579-730e3918a45a?auto=format&fit=crop&q=80&w=800',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: bannerBgColor,
                  ),
                ),
              ),

              // 2. Horizontal Color Shade Gradient Fade into Image (Exact effect from reference)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: const [0.0, 0.38, 0.72, 1.0],
                      colors: [
                        bannerBgColor,
                        bannerBgColor,
                        bannerBgColor.withOpacity(0.45),
                        bannerBgColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Subtle Ambient Light Flare Effect (matching reference screenshot)
              Positioned(
                left: MediaQuery.of(context).size.width * 0.36,
                top: 15,
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Left Side Typography matching reference screenshot
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '20',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                                TextSpan(
                                  text: '% ',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Save',
                            style: GoogleFonts.caveat(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.48,
                        child: Text(
                          'On bookings for Spring Weddings!!',
                          style: GoogleFonts.caveat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

