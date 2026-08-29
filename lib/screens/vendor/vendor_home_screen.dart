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
import 'vendor_availability_screen.dart';
import 'vendor_analytics_screen.dart';
import 'vendor_requests_screen.dart';
import 'vendor_profile_screen.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<FloatingNavItem> _navItems = [
    FloatingNavItem(
      activeIcon: Icons.grid_view_rounded,
      inactiveIcon: Icons.grid_view_outlined,
      label: 'Dashboard',
    ),
    FloatingNavItem(
      activeIcon: Icons.menu_book_rounded,
      inactiveIcon: Icons.menu_book_outlined,
      label: 'Bookings',
    ),
    FloatingNavItem(
      activeIcon: Icons.layers_rounded,
      inactiveIcon: Icons.layers_outlined,
      label: 'My Services',
    ),
    FloatingNavItem(
      activeIcon: Icons.calendar_today_rounded,
      inactiveIcon: Icons.calendar_today_outlined,
      label: 'Availability',
    ),
    FloatingNavItem(
      activeIcon: Icons.person_rounded,
      inactiveIcon: Icons.person_outline_rounded,
      label: 'Profile',
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
    final authProvider = context.read<AuthProvider>();
    final vendorAuthProvider = context.read<VendorAuthProvider>();
    await vendorAuthProvider.logout();
    authProvider.clearRole();
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
    } else if (routeName == '/vendor/availability') {
      nav.setIndex(3);
    } else if (routeName == '/vendor/profile') {
      nav.setIndex(4);
    } else if (routeName == '/vendor/analytics') {
      nav.setIndex(5);
    } else if (routeName == '/vendor/requests') {
      nav.setIndex(6);
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
                  index: nav.currentIndex.clamp(0, 6),
                  children: const [
                    _VendorDashboardBody(),
                    VendorBookingsScreen(),
                    VendorServicesScreen(),
                    VendorAvailabilityScreen(),
                    VendorProfileScreen(),
                    VendorAnalyticsScreen(),
                    VendorRequestsScreen(),
                  ],
                ),
              ),
            ],
          ),

          // Floating Bottom Navigation Bar for Vendor on all screens
          FloatingNavBarWidget(
            currentIndex: nav.currentIndex.clamp(0, 4),
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

class _VendorDashboardBody extends StatefulWidget {
  const _VendorDashboardBody();

  @override
  State<_VendorDashboardBody> createState() => _VendorDashboardBodyState();
}

class _VendorDashboardBodyState extends State<_VendorDashboardBody> {
  bool _profileCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<VendorPortalProvider>();
    final vendorAuth = context.watch<VendorAuthProvider>();
    final token = vendorAuth.token ?? '';
    final vendorName = portal.profile?.name.isNotEmpty == true
        ? portal.profile!.name
        : vendorAuth.vendorName;

    final pendingBookings = portal.bookings.where((b) => b.status.toLowerCase() == 'pending').toList();
    final pendingRequests = portal.serviceRequests.where((r) => r.status.toLowerCase() == 'pending').toList();

    return RefreshIndicator(
      color: AppColors.brandPink,
      onRefresh: () => portal.loadAll(token),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Welcome Card Matching React
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.brandPink,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPink.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VENDOR PORTAL',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppColors.champagne,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Assalam-o-Alaikum, $vendorName!',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Here is an overview of the services you offer on EventITT and the bookings assigned to you.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () => context.read<NavigationProvider>().setIndex(2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View My Services',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandPink,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.brandPink),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. 4 Top Stat Cards Exactly as React
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Active Services',
                    subtitle: 'Live offerings',
                    value: '${portal.activeServicesCount}',
                    icon: Icons.layers_outlined,
                    color: AppColors.brandPink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Upcoming Bookings',
                    subtitle: 'Next 30 days',
                    value: '${portal.upcomingCount}',
                    icon: Icons.calendar_today_outlined,
                    color: AppColors.primaryGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Bookings This Month',
                    subtitle: 'Current month',
                    value: '${portal.monthCount}',
                    icon: Icons.event_available_outlined,
                    color: AppColors.softCoral,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Profile Completion',
                    subtitle: 'Setup progress',
                    value: '${portal.profileCompletionPercentage}%',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Profile Completion Checklist
            _buildProfileCompletionCard(context, portal),
            const SizedBox(height: 16),

            // 4. Priority Actions Alert Banner (Matching React)
            if (pendingBookings.isNotEmpty || pendingRequests.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.discountOrange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.discountOrange, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Priority Actions',
                          style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (pendingBookings.isNotEmpty)
                      InkWell(
                        onTap: () => context.read<NavigationProvider>().setIndex(1),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.brandPink.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.brandPink.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.inbox_outlined, color: AppColors.brandPink, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${pendingBookings.length} pending booking${pendingBookings.length == 1 ? '' : 's'} to review',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.brandPink),
                            ],
                          ),
                        ),
                      ),
                    if (pendingRequests.isNotEmpty)
                      InkWell(
                        onTap: () => context.read<NavigationProvider>().setIndex(6),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule_outlined, color: AppColors.primaryGold, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${pendingRequests.length} pending service request${pendingRequests.length == 1 ? '' : 's'}',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primaryGold),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 5. Upcoming Bookings Card (Next 5)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.lightGrey),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, color: AppColors.brandPink, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Upcoming Bookings',
                            style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.brandPink.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Next 5',
                          style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandPink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (portal.upcomingBookings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No upcoming bookings assigned to you yet.',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                        ),
                      ),
                    )
                  else
                    ...portal.upcomingBookings.map((b) => _buildUpcomingBookingRow(b)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 6. Your Categories Preview
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.category_outlined, color: AppColors.primaryGold, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Your Categories',
                            style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => context.read<NavigationProvider>().setIndex(2),
                        child: Text(
                          'Manage Services →',
                          style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandPink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (portal.serviceHierarchy.isEmpty)
                    Text('No services linked yet. Request offerings to get started.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: portal.serviceHierarchy.expand((s) => s.categories).map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.brandPink.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            '${cat.categoryName} (${cat.subcategories.length})',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brandPink),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 7. Booking Insights Summary Breakdown
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trending_up_rounded, color: AppColors.brandPink, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Booking Insights',
                            style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => context.read<NavigationProvider>().setIndex(5),
                        child: Text(
                          'Full Analytics →',
                          style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandPink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOTAL REVENUE', style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMedium)),
                              const SizedBox(height: 4),
                              Text('Rs ${portal.totalRevenue.toStringAsFixed(0)}', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              Text('All active bookings', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textLight)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOTAL BOOKINGS', style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMedium)),
                              const SizedBox(height: 4),
                              Text('${portal.totalBookings}', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              Text('Assigned in total', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textLight)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingBookingRow(dynamic b) {
    String month = '—';
    String day = '—';
    if (b.eventDate != null) {
      final dt = DateTime.tryParse(b.eventDate!);
      if (dt != null) {
        const mNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        month = mNames[dt.month - 1];
        day = '${dt.day}';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brandPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(month.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.brandPink)),
                Text(day, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.customerName ?? 'Customer',
                  style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                Text(
                  b.subcategoryName ?? b.serviceName ?? 'Service Offering',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              b.statusLabel,
              style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.successGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard(BuildContext context, VendorPortalProvider portal) {
    final pct = portal.profileCompletionPercentage;
    final isComplete = pct >= 100;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _profileCollapsed = !_profileCollapsed),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isComplete ? Icons.check_circle_rounded : Icons.settings_suggest_rounded,
                    color: isComplete ? AppColors.successGreen : AppColors.brandPink,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isComplete ? 'Your Eventitt profile is complete' : 'Complete Your Eventitt Profile',
                      style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isComplete ? AppColors.successGreen : AppColors.brandPink).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$pct%',
                      style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: isComplete ? AppColors.successGreen : AppColors.brandPink),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _profileCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    color: AppColors.textMedium,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (!_profileCollapsed) ...[
            const Divider(height: 1, color: AppColors.lightGrey),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...portal.profileChecks.map((chk) {
                    final done = chk['complete'] == true;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: done ? AppColors.successGreen : AppColors.textLight,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            chk['label'] as String,
                            style: GoogleFonts.inter(fontSize: 12, color: done ? AppColors.textDark : AppColors.textMedium),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.read<NavigationProvider>().setIndex(4),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brandPink,
                        side: const BorderSide(color: AppColors.brandPink),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Edit Profile Details', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.subtitle,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
