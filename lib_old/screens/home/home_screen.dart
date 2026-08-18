import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
import '../dashboard_overview/dashboard_overview_screen.dart';
import '../login/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _handleDrawerNavigation(String routeName) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    if (routeName == '/home') {
      navProvider.setIndex(0);
    } else if (routeName == '/dashboard') {
      navProvider.setIndex(1);
    } else if (routeName == '/services') {
      navProvider.setIndex(2);
    } else if (routeName == '/categories') {
      navProvider.setIndex(3);
    } else if (routeName == '/login') {
      Navigator.of(context).pushReplacement(AppAnimations.fadeInRoute(const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.lightBackground,
      drawer: CustomDrawerWidget(
        onNavigationSelected: _handleDrawerNavigation,
      ),
      body: Stack(
        children: [
          // Column containing Persistent Top Curved Header + Active Screen View Body
          Column(
            children: [
              // Persistent Top Curved App Bar Header matching Image 2
              CustomHeaderWidget(
                onDrawerTap: () => _scaffoldKey.currentState?.openDrawer(),
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No new notifications')),
                  );
                },
                onLocationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Current Location: Udaipur, Rajasthan')),
                  );
                },
              ),

              // Dynamic Tab Body Content with Persistent Header & Floating Bottom Nav
              Expanded(
                child: IndexedStack(
                  index: navProvider.currentIndex,
                  children: [
                    // Tab Index 0: Home Main Screen Content (Exact Image 2)
                    const _HomeMainContent(),

                    // Tab Index 1: Dashboard Overview & Stats View
                    const DashboardOverviewScreen(),

                    // Tab Index 2: Services View
                    const ServicesScreenBody(),

                    // Tab Index 3: Categories & Sub-Categories View
                    const CategoriesScreenBody(),
                  ],
                ),
              ),
            ],
          ),

          // Floating Bottom Navigation Bar Widget (Persistent across all tabs!)
          FloatingNavBarWidget(
            currentIndex: navProvider.currentIndex,
            onTap: (index) {
              navProvider.setIndex(index);
            },
          ),
        ],
      ),
    );
  }
}

// Extracted Home Screen Main Scrollable View Content
class _HomeMainContent extends StatelessWidget {
  const _HomeMainContent();

  @override
  Widget build(BuildContext context) {
    final venueProvider = Provider.of<VenueProvider>(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Search Bar Widget ("Where are you going?")
        SliverToBoxAdapter(
          child: SearchBarWidget(
            onChanged: (query) => venueProvider.setSearchQuery(query),
            onFilterTap: () => _showFilterBottomSheet(context),
          ),
        ),

        // Hero Banner Widget ("Your Dream Venue Awaits")
        SliverToBoxAdapter(
          child: HeroBannerWidget(
            onExploreTap: () {},
          ),
        ),

        // Categories Header & Horizontal Carousel
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
                  onTap: () {
                    Provider.of<NavigationProvider>(context, listen: false).setIndex(3);
                  },
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

        // Horizontal Categories List (Mehndi, Photography, Wedding)
        SliverToBoxAdapter(
          child: SizedBox(
            height: 142,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: venueProvider.categories.length,
              itemBuilder: (context, index) {
                final category = venueProvider.categories[index];
                final isSelected = venueProvider.selectedCategoryTitle == category.title;
                return CategoryCardWidget(
                  category: category,
                  isSelected: isSelected,
                  onTap: () {
                    venueProvider.selectCategory(category.title);
                  },
                );
              },
            ),
          ),
        ),

        // Spring Promo Banner ("20% Save On bookings for Spring Weddings!")
        SliverToBoxAdapter(
          child: PromoBannerWidget(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Spring promo discount applied!')),
              );
            },
          ),
        ),

        // Venues List Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Venues',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
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

        // Venues Cards List with Custom Cutout Card Detail UI
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final venue = venueProvider.venues[index];
              return VenueCardWidget(
                venue: venue,
                onTap: () {
                  Navigator.of(context).push(
                    AppAnimations.slideUpRoute(VenueDetailScreen(venue: venue)),
                  );
                },
                onFavoriteToggle: () {
                  venueProvider.toggleFavorite(venue.id);
                },
                onShareTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Share link created for ${venue.title}')),
                  );
                },
              );
            },
            childCount: venueProvider.venues.length,
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Venues',
                style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Price Range: \$50,000 - \$5,00,000', style: GoogleFonts.inter(fontSize: 14)),
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
        );
      },
    );
  }
}
