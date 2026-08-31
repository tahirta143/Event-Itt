import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/customer_auth_provider.dart';
import '../../providers/venue/venue_provider.dart';
import '../../providers/navigation/navigation_provider.dart';
import '../../utils/colors/app_colors.dart';
import '../../utils/animations/app_animations.dart';
import '../../widgets/custom_header/custom_header_widget.dart';
import '../../widgets/search_bar/search_bar_widget.dart';
import '../../widgets/hero_banner/hero_banner_widget.dart';
import '../../widgets/category_card/category_card_widget.dart';
import '../../widgets/promo_banner/promo_banner_widget.dart';
import '../../widgets/venue_card/venue_card_widget.dart';
import '../../widgets/floating_nav_bar/floating_nav_bar_widget.dart';
import '../../widgets/custom_drawer/custom_drawer_widget.dart';
import '../venue_detail/venue_detail_screen.dart';
import '../categories/categories_screen.dart';
import '../services/services_screen.dart';
import '../login/login_screen.dart';
import '../../models/subcategory/subcategory_model.dart';
import '../subcategory_detail/subcategory_detail_screen.dart';
import 'customer_bookings_screen.dart';
import 'customer_booking_flow_sheet.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<FloatingNavItem> _navItems = [
    FloatingNavItem(
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
      label: 'Home',
    ),
    FloatingNavItem(
      activeIcon: Icons.calendar_month_rounded,
      inactiveIcon: Icons.calendar_month_outlined,
      label: 'My Bookings',
    ),
    FloatingNavItem(
      activeIcon: Icons.category_rounded,
      inactiveIcon: Icons.category_outlined,
      label: 'Categories',
    ),
    FloatingNavItem(
      activeIcon: Icons.room_service_rounded,
      inactiveIcon: Icons.room_service_outlined,
      label: 'Services',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VenueProvider>().fetchPublicData();
    });
  }

  void _logout() async {
    final authProvider = context.read<AuthProvider>();
    final customerAuth = context.read<CustomerAuthProvider>();
    await customerAuth.logout();
    authProvider.clearRole();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      AppAnimations.fadeInRoute(const LoginScreen()),
    );
  }

  void _handleDrawerNavigation(String routeName) {
    final nav = context.read<NavigationProvider>();
    if (routeName == '/customer/home') {
      nav.setIndex(0);
    } else if (routeName == '/customer/bookings') {
      nav.setIndex(1);
    } else if (routeName == '/categories') {
      nav.setIndex(2);
    } else if (routeName == '/services') {
      nav.setIndex(3);
    } else if (routeName == '/login') {
      _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightBackground,
      drawer: CustomDrawerWidget(
        onNavigationSelected: _handleDrawerNavigation,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              CustomHeaderWidget(
                onDrawerTap: () => _scaffoldKey.currentState?.openDrawer(),
                onNotificationTap: () {},
                onLocationTap: () {},
              ),

              Expanded(
                child: IndexedStack(
                  index: nav.currentIndex.clamp(0, 3),
                  children: const [
                    _CustomerMainContent(), // 0 - Home
                    CustomerBookingsScreen(), // 1 - My Bookings
                    CategoriesScreenBody(), // 2 - Categories
                    ServicesScreenBody(), // 3 - Services
                  ],
                ),
              ),
            ],
          ),

          // Bottom Floating Nav Bar
          FloatingNavBarWidget(
            currentIndex: nav.currentIndex.clamp(0, 3),
            onTap: (index) => nav.setIndex(index),
            items: _navItems,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Customer Main Content with dual vertical and horizontal scroll pagination
// ---------------------------------------------------------------------------

class _CustomerMainContent extends StatefulWidget {
  const _CustomerMainContent();

  @override
  State<_CustomerMainContent> createState() => _CustomerMainContentState();
}

class _CustomerMainContentState extends State<_CustomerMainContent> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalCategoryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _verticalScrollController.addListener(_onVerticalScroll);
    _horizontalCategoryScrollController.addListener(_onHorizontalCategoryScroll);
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalCategoryScrollController.dispose();
    super.dispose();
  }

  void _onVerticalScroll() {
    if (_verticalScrollController.position.pixels >=
        _verticalScrollController.position.maxScrollExtent - 200) {
      final provider = context.read<VenueProvider>();
      if (!provider.isLoadingMoreVenues && provider.hasMoreVenues) {
        provider.loadMoreVenuesOnScroll();
      }
    }
  }

  void _onHorizontalCategoryScroll() {
    if (_horizontalCategoryScrollController.position.pixels >=
        _horizontalCategoryScrollController.position.maxScrollExtent - 100) {
      final provider = context.read<VenueProvider>();
      if (!provider.isLoadingMoreCategories && provider.hasMoreCategories) {
        provider.loadMoreCategoriesOnScroll();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final venueProvider = context.watch<VenueProvider>();

    if (venueProvider.isLoading && venueProvider.venues.isEmpty && venueProvider.categories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.brandPink,
      onRefresh: () => venueProvider.fetchPublicData(),
      child: CustomScrollView(
        controller: _verticalScrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: SearchBarWidget(
              onChanged: (query) => venueProvider.setSearchQuery(query),
              onFilterTap: () => _showFilterSheet(context),
            ),
          ),
          SliverToBoxAdapter(
            child: HeroBannerWidget(onExploreTap: () {}),
          ),

          // Categories carousel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.read<NavigationProvider>().setIndex(2),
                    child: Text(
                      'View All',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMedium,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 142,
              child: ListView.builder(
                controller: _horizontalCategoryScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: venueProvider.categories.length + (venueProvider.isLoadingMoreCategories ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= venueProvider.categories.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandPink),
                        ),
                      ),
                    );
                  }
                  final cat = venueProvider.categories[index];
                  return CategoryCardWidget(
                    category: cat,
                    isSelected: venueProvider.selectedCategoryTitle == cat.title,
                    onTap: () => venueProvider.selectCategory(cat.title),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: PromoBannerWidget(onTap: () {}),
          ),

          // Main Offerings & Venues Header
          Builder(
            builder: (context) {
              final isAll = venueProvider.selectedCategoryTitle == 'All';
              final matchingSubs = isAll
                  ? <SubCategoryModel>[]
                  : venueProvider.subCategories.where((s) {
                      if (s.categoryName != null) {
                        return s.categoryName!.toLowerCase() ==
                            venueProvider.selectedCategoryTitle.toLowerCase();
                      }
                      final matchedCat = venueProvider.categories.where((c) =>
                          c.title.toLowerCase() ==
                          venueProvider.selectedCategoryTitle.toLowerCase());
                      if (matchedCat.isNotEmpty) {
                        return s.categoryId == matchedCat.first.id;
                      }
                      return false;
                    }).toList();

              final matchingVenues = isAll
                  ? venueProvider.venues
                  : venueProvider.venues.where((v) =>
                      v.category.toLowerCase() ==
                      venueProvider.selectedCategoryTitle.toLowerCase()).toList();

              final totalItems = matchingSubs.length + matchingVenues.length;

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAll ? 'Venues & Offerings' : '${venueProvider.selectedCategoryTitle} Offerings',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (!isAll && totalItems > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$totalItems Available',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Main Unified Feed: Large Subcategory Cards & Venue Cards
          Builder(
            builder: (context) {
              final isAll = venueProvider.selectedCategoryTitle == 'All';
              final matchingSubs = isAll
                  ? <SubCategoryModel>[]
                  : venueProvider.subCategories.where((s) {
                      if (s.categoryName != null) {
                        return s.categoryName!.toLowerCase() ==
                            venueProvider.selectedCategoryTitle.toLowerCase();
                      }
                      final matchedCat = venueProvider.categories.where((c) =>
                          c.title.toLowerCase() ==
                          venueProvider.selectedCategoryTitle.toLowerCase());
                      if (matchedCat.isNotEmpty) {
                        return s.categoryId == matchedCat.first.id;
                      }
                      return false;
                    }).toList();

              final matchingVenues = isAll
                  ? venueProvider.venues
                  : venueProvider.venues.where((v) =>
                      v.category.toLowerCase() ==
                      venueProvider.selectedCategoryTitle.toLowerCase()).toList();

              if (!isAll && matchingSubs.isEmpty && matchingVenues.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.brandPink.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.room_service_outlined,
                              size: 40, color: AppColors.brandPink),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No Offerings for ${venueProvider.selectedCategoryTitle}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Select another category or view all options.',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textMedium),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < matchingSubs.length) {
                      final sub = matchingSubs[index];
                      return _buildLargeSubCategoryCard(
                        context,
                        sub,
                        venueProvider.selectedCategoryTitle,
                      );
                    }

                    final venueIndex = index - matchingSubs.length;
                    final venue = matchingVenues[venueIndex];
                    return VenueCardWidget(
                      venue: venue,
                      onTap: () => Navigator.of(context).push(
                        AppAnimations.slideUpRoute(VenueDetailScreen(venue: venue)),
                      ),
                      onFavoriteToggle: () => venueProvider.toggleFavorite(venue.id),
                      onShareTap: () {},
                    );
                  },
                  childCount: matchingSubs.length + matchingVenues.length,
                ),
              );
            },
          ),

          if (venueProvider.isLoadingMoreVenues)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildLargeSubCategoryCard(
      BuildContext context, SubCategoryModel sub, String categoryName) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubcategoryDetailScreen(
                  subCategory: sub,
                  categoryName: categoryName,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Large Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    sub.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.brandPink.withOpacity(0.1),
                      child: const Icon(Icons.celebration_rounded,
                          color: AppColors.brandPink, size: 48),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        categoryName,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                if (sub.description != null && sub.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    sub.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.lightGrey),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starting From',
                          style: GoogleFonts.inter(
                              fontSize: 10, color: AppColors.textLight),
                        ),
                        Text(
                          sub.basePrice != null && sub.basePrice! > 0
                              ? 'PKR ${sub.basePrice!.toStringAsFixed(0)}'
                              : 'Price on quotation',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
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
                            horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        CustomerBookingFlowSheet.show(
                          context,
                          subcategoryId: sub.id,
                          subcategoryName: sub.title,
                          categoryName: categoryName,
                        );
                      },
                      icon: const Icon(Icons.calendar_month_rounded, size: 16),
                      label: Text(
                        'Book This',
                        style: GoogleFonts.montserrat(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
}

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Venues', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Price Range: Rs 50,000 - Rs 5,00,000', style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 8),
            Text('Guest Capacity: 200 - 2000 Guests', style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkHeader,
                  foregroundColor: AppColors.textWhite,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
