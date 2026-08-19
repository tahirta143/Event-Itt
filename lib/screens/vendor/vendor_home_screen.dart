import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/vendor_auth_provider.dart';
import '../../providers/vendor/vendor_portal_provider.dart';
import '../../providers/navigation/navigation_provider.dart';
import '../../utils/colors/app_colors.dart';
import '../../utils/animations/app_animations.dart';
import '../../widgets/custom_header/custom_header_widget.dart';
import '../../widgets/custom_drawer/custom_drawer_widget.dart';
import '../../widgets/floating_nav_bar/floating_nav_bar_widget.dart';
import '../../screens/login/login_screen.dart';
import 'vendor_bookings_screen.dart';
import 'vendor_services_screen.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<FloatingNavItem> _navItems = [
    FloatingNavItem(
      activeIcon: Icons.dashboard_outlined,
      inactiveIcon: Icons.dashboard_outlined,
      label: 'Dashboard',
    ),
    FloatingNavItem(
      activeIcon: Icons.calendar_month_outlined,
      inactiveIcon: Icons.calendar_month_outlined,
      label: 'Bookings',
    ),
    FloatingNavItem(
      activeIcon: Icons.room_service_outlined,
      inactiveIcon: Icons.room_service_outlined,
      label: 'My Services',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<VendorAuthProvider>().token ?? '';
      context.read<VendorPortalProvider>().loadAll(token);
    });
  }

  void _logout() async {
    await context.read<VendorAuthProvider>().logout();
    context.read<AuthProvider>().clearRole();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      AppAnimations.fadeInRoute(const LoginScreen()),
    );
  }

  void _handleDrawerNavigation(String routeName) {
    final nav = context.read<NavigationProvider>();
    if (routeName == '/vendor/home') {
      nav.setIndex(0);
    } else if (routeName == '/vendor/bookings') {
      nav.setIndex(1);
    } else if (routeName == '/vendor/services') {
      nav.setIndex(2);
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
                  index: nav.currentIndex.clamp(0, 2),
                  children: const [
                    _VendorDashboardBody(),
                    VendorBookingsScreen(),
                    VendorServicesScreen(),
                  ],
                ),
              ),
            ],
          ),

          // Floating Bottom Navigation Bar for Vendor
          FloatingNavBarWidget(
            currentIndex: nav.currentIndex.clamp(0, 2),
            onTap: (index) => nav.setIndex(index),
            items: _navItems,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vendor Dashboard Body
// ---------------------------------------------------------------------------

class _VendorDashboardBody extends StatelessWidget {
  const _VendorDashboardBody();

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<VendorPortalProvider>();
    final vendorAuth = context.watch<VendorAuthProvider>();

    if (portal.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vendor Portal',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            'Welcome, ${vendorAuth.businessName}',
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.textMedium),
          ),
          const SizedBox(height: 16),

          // Stats grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              _VendorStatCard(
                label: 'Total Bookings',
                value: portal.totalBookings.toString(),
                icon: Icons.calendar_month_outlined,
                color: AppColors.brandPink,
              ),
              _VendorStatCard(
                label: 'Pending',
                value: portal.pendingBookings.toString(),
                icon: Icons.hourglass_top_outlined,
                color: AppColors.discountOrange,
              ),
              _VendorStatCard(
                label: 'Confirmed',
                value: portal.confirmedBookings.toString(),
                icon: Icons.check_circle_outlined,
                color: AppColors.successGreen,
              ),
              _VendorStatCard(
                label: 'Revenue',
                value: 'Rs ${(portal.totalRevenue / 1000).toStringAsFixed(0)}K',
                icon: Icons.payments_outlined,
                color: AppColors.brandPink,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // My services preview
          if (portal.services.isNotEmpty) ...[
            Text(
              'My Services',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            ...portal.services.take(3).map((svc) {
              final name = svc['name']?.toString() ??
                  svc['title']?.toString() ??
                  'Service';
              final category =
                  svc['categoryName']?.toString() ?? '';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.room_service_outlined,
                          color: AppColors.primaryGold, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark)),
                          if (category.isNotEmpty)
                            Text(category,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textMedium)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _VendorStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _VendorStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textMedium),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
