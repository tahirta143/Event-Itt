import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/category/category_model.dart';
import '../../utils/colors/app_colors.dart';

class CategoryCardWidget extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCardWidget({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkBackground : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? AppColors.darkBackground : AppColors.lightGrey,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Top Image Container with Rounded Top Corners
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Image.network(
                category.imageUrl,
                height: 95,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: 200, // Memory and decode cache optimization
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 95,
                    color: AppColors.lightGrey,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
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
                  height: 95,
                  color: AppColors.lightGrey,
                  child: const Icon(Icons.image, color: AppColors.textLight),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                category.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
