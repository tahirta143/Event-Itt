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
import 'customer_bookings_screen.dart';

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

          // Venues
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 14),
              child: Text(
                'Venues',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final venue = venueProvider.venues[index];
                return VenueCardWidget(
                  venue: venue,
                  onTap: () => Navigator.of(context).push(
                    AppAnimations.slideUpRoute(VenueDetailScreen(venue: venue)),
                  ),
                  onFavoriteToggle: () => venueProvider.toggleFavorite(venue.id),
                  onShareTap: () {},
                );
              },
              childCount: venueProvider.venues.length,
            ),
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
