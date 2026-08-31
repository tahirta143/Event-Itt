import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_client.dart';
import '../../models/subcategory/subcategory_model.dart';
import '../../utils/colors/app_colors.dart';
import '../customer/customer_booking_flow_sheet.dart';

class SubcategoryDetailScreen extends StatefulWidget {
  final SubCategoryModel subCategory;
  final String? categoryName;

  const SubcategoryDetailScreen({
    super.key,
    required this.subCategory,
    this.categoryName,
  });

  @override
  State<SubcategoryDetailScreen> createState() =>
      _SubcategoryDetailScreenState();
}

class _SubcategoryDetailScreenState extends State<SubcategoryDetailScreen> {
  bool _loading = false;
  Map<String, dynamic>? _apiData;
  List<dynamic> _vendors = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _loading = true);
    final client = ApiClient();
    try {
      final res =
          await client.get('/api/public/subcategories/${widget.subCategory.id}');
      if (res.success && res.data != null && res.data is Map<String, dynamic>) {
        if (mounted) {
          setState(() {
            _apiData = res.data as Map<String, dynamic>;
            _vendors = (_apiData!['vendors'] as List?) ?? [];
          });
        }
      }
    } catch (_) {
      // Gracefully fallback to subCategory model data
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _resolveVendorImage(dynamic logoUrl) {
    if (logoUrl == null || logoUrl.toString().isEmpty) {
      return 'https://images.unsplash.com/photo-1519741497674-611481863552?w=500&q=80';
    }
    final url = logoUrl.toString();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return 'https://api.eventitt.afaqmis.com$url';
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.subCategory;
    final catName = widget.categoryName ?? sub.categoryName ?? 'Wedding Service';
    final priceStr = sub.basePrice != null && sub.basePrice! > 0
        ? 'PKR ${sub.basePrice!.toStringAsFixed(0)}'
        : 'Price on quotation';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero App Bar with Cover Image
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.darkHeader,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        sub.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.brandPink.withOpacity(0.15),
                          child: const Center(
                            child: Icon(Icons.celebration_rounded,
                                size: 64, color: AppColors.brandPink),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                              Colors.black.withOpacity(0.85),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                catName.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sub.title,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Breadcrumb Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.category_outlined,
                                color: AppColors.primaryGold, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$catName › ${sub.title}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // About this offering
                      Text(
                        'About This Offering',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Text(
                          sub.description != null &&
                                  sub.description!.trim().isNotEmpty
                              ? sub.description!
                              : 'Experience unmatched luxury and exceptional service customized specifically for your wedding ceremonies.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Vendors list header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured Vendors',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Verified Partners',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Vendors list
                      if (_vendors.isNotEmpty)
                        ..._vendors.map((v) {
                          final name = v['name']?.toString() ?? 'Vendor';
                          final addr = v['address']?.toString() ?? 'Pakistan';
                          final rating =
                              v['average_rating']?.toString() ?? '4.9';
                          final logo = _resolveVendorImage(v['logo_url']);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.lightGrey),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    logo,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 50,
                                      height: 50,
                                      color:
                                          AppColors.brandPink.withOpacity(0.1),
                                      child: const Icon(Icons.store_rounded,
                                          color: AppColors.brandPink),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined,
                                              size: 14,
                                              color: AppColors.textLight),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              addr,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: AppColors.textLight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryGold.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          size: 14,
                                          color: AppColors.primaryGold),
                                      const SizedBox(width: 2),
                                      Text(
                                        rating,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.lightGrey),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_user_rounded,
                                  color: AppColors.primaryGold, size: 28),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'Serviced by top-rated certified EventITT wedding vendors across Pakistan.',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Floating Sticky CTA Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Starting Base Price',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          priceStr,
                          style: GoogleFonts.montserrat(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        CustomerBookingFlowSheet.show(
                          context,
                          subcategoryId: sub.id,
                          subcategoryName: sub.title,
                          categoryName: catName,
                        );
                      },
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: Text(
                        'Book This',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
