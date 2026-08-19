import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/venue/venue_provider.dart';
import '../../providers/navigation/navigation_provider.dart';
import '../../utils/colors/app_colors.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Categories & Sub-Categories',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: const CategoriesScreenBody(),
    );
  }
}

class CategoriesScreenBody extends StatelessWidget {
  const CategoriesScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final venueProvider = Provider.of<VenueProvider>(context);

    if (venueProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
        ),
      );
    }

    final categories = venueProvider.categories.where((c) => c.id != 'all').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Event Categories',
            style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 14),

          // Main Categories Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.95,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  venueProvider.selectCategory(cat.title);
                  Provider.of<NavigationProvider>(context, listen: false).setIndex(0);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            cat.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.brandPink.withOpacity(0.1),
                              child: const Icon(Icons.category_outlined, color: AppColors.brandPink, size: 32),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat.title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                            const SizedBox(height: 2),
                            Text('${cat.itemQuantity}+ Options', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          Text(
            'Popular Sub-Categories',
            style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 14),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: venueProvider.subCategories.length,
            itemBuilder: (context, index) {
              final subCat = venueProvider.subCategories[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        subCat.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.brandPink.withOpacity(0.1),
                          child: const Icon(Icons.category_outlined, color: AppColors.brandPink, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(subCat.title, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(height: 4),
                          Text('Available on EventITT', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_outlined, size: 16, color: AppColors.textMedium),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
