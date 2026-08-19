import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../models/venue/venue_model.dart';
import '../../utils/colors/app_colors.dart';

class VenueCardWidget extends StatefulWidget {
  final VenueModel venue;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onShareTap;

  const VenueCardWidget({
    super.key,
    required this.venue,
    required this.onTap,
    required this.onFavoriteToggle,
    this.onShareTap,
  });

  @override
  State<VenueCardWidget> createState() => _VenueCardWidgetState();
}

class _VenueCardWidgetState extends State<VenueCardWidget> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Carousel Stack with Favorite Heart & Dots Indicator
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.venue.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.venue.images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.lightGrey,
                            child: const Icon(Icons.image, size: 40, color: AppColors.textLight),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Top Right Favorite Button (Heart)
                Positioned(
                  top: 14,
                  right: 14,
                  child: GestureDetector(
                    onTap: widget.onFavoriteToggle,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        widget.venue.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: widget.venue.isFavorite ? AppColors.softCoral : AppColors.textWhite,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Bottom Page Indicator Dots
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: widget.venue.images.length,
                      effect: const ExpandingDotsEffect(
                        dotHeight: 6,
                        dotWidth: 6,
                        activeDotColor: AppColors.cardWhite,
                        dotColor: Colors.white54,
                        expansionFactor: 3,
                        spacing: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Content Details with Bottom Right Cutout Action Button
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.venue.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_outline_rounded,
                                color: AppColors.starRating,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.venue.rating.toStringAsFixed(1),
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Location Subtitle
                      Text(
                        widget.venue.location,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Price Tag
                      Text(
                        widget.venue.price,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Right Action/Share Cutout Button (Matching Image 2 detail callout)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: widget.onShareTap,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.darkHeader,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.ios_share_outlined,
                        color: AppColors.textWhite,
                        size: 20,
                      ),
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
