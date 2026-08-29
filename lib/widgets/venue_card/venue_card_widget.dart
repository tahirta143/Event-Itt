import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/venue/venue_model.dart';
import '../../utils/colors/app_colors.dart';

class VenueCardWidget extends StatefulWidget {
  final VenueModel venue;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onShareTap;

  const VenueCardWidget({
    super.key,
    required this.venue,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onShareTap,
  });

  @override
  State<VenueCardWidget> createState() => _VenueCardWidgetState();
}

class _VenueCardWidgetState extends State<VenueCardWidget> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

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
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppColors.lightGrey,
            width: 1,
          ),
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
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.venue.images[index],
                          fit: BoxFit.cover,
                          cacheWidth: 600, // Faster decode & render
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.lightGrey,
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandPink),
                                  ),
                                ),
                              ),
                            );
                          },
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
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
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
                if (widget.venue.images.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.venue.images.length,
                        (dotIndex) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 6,
                          width: _currentImageIndex == dotIndex ? 18 : 6,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == dotIndex
                                ? AppColors.cardWhite
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Bottom Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Category Tag & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.brandPink.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.venue.category.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.brandPink,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.primaryGold, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            widget.venue.rating.toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            ' (${widget.venue.reviewsCount})',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Row 2: Venue Title
                  Text(
                    widget.venue.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Row 3: Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.brandPink),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.venue.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const Divider(height: 1, color: AppColors.lightGrey),
                  const SizedBox(height: 12),

                  // Row 4: Price and Capacity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Starting from',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.textLight,
                            ),
                          ),
                          Text(
                            widget.venue.price,
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandPink,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 16, color: AppColors.textMedium),
                          const SizedBox(width: 4),
                          Text(
                            widget.venue.capacity,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
