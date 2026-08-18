import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor/vendor_portal_provider.dart';
import '../../utils/colors/app_colors.dart';

class VendorServicesScreen extends StatelessWidget {
  const VendorServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<VendorPortalProvider>();

    if (portal.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
        ),
      );
    }

    if (portal.services.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.room_service_outlined,
                size: 48, color: AppColors.textLight),
            const SizedBox(height: 12),
            Text(
              'No services yet.',
              style: GoogleFonts.inter(color: AppColors.textMedium),
            ),
            const SizedBox(height: 6),
            Text(
              'Contact admin to get services assigned.',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: portal.services.length + 1,
      itemBuilder: (context, index) {
        if (index == portal.services.length) return const SizedBox(height: 100);
        final svc = portal.services[index];
        final name =
            svc['name']?.toString() ?? svc['title']?.toString() ?? 'Service';
        final category =
            svc['categoryName']?.toString() ?? svc['category']?.toString() ?? '';
        final price = svc['price']?.toString() ??
            svc['startingPrice']?.toString() ??
            '';
        final imageUrl = svc['image']?.toString() ?? svc['imageUrl']?.toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.lightGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (category.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        category,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textMedium),
                      ),
                    ],
                    if (price.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Rs $price',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _placeholder() => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.room_service_rounded,
          color: AppColors.textLight,
          size: 32,
        ),
      );
}
