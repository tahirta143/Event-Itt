import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/admin_auth_provider.dart';
import '../../providers/admin/admin_dashboard_provider.dart';
import '../../providers/navigation/navigation_provider.dart';
import '../../utils/colors/app_colors.dart';
import '../../utils/animations/app_animations.dart';
import '../../widgets/custom_header/custom_header_widget.dart';
import '../../widgets/custom_drawer/custom_drawer_widget.dart';
import '../../widgets/floating_nav_bar/floating_nav_bar_widget.dart';
import '../../screens/login/login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_vendors_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_vendor_requests_screen.dart';
import 'admin_contact_inbox_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<FloatingNavItem> _navItems = [
    FloatingNavItem(
      activeIcon: Icons.dashboard_customize_rounded,
      inactiveIcon: Icons.dashboard_customize_outlined,
      label: 'Home',
    ),
    FloatingNavItem(
      activeIcon: Icons.calendar_month_rounded,
      inactiveIcon: Icons.calendar_month_outlined,
      label: 'Bookings',
    ),
    FloatingNavItem(
      activeIcon: Icons.storefront_rounded,
      inactiveIcon: Icons.storefront_outlined,
      label: 'Vendors',
    ),
    FloatingNavItem(
      activeIcon: Icons.people_rounded,
      inactiveIcon: Icons.people_outline_rounded,
      label: 'Customers',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final token = context.read<AdminAuthProvider>().token ?? '';
    context.read<AdminDashboardProvider>().loadSummary(token);
    context.read<AdminDashboardProvider>().loadRecentBookings(token);
  }

  void _logout() async {
    await context.read<AdminAuthProvider>().logout();
    context.read<AuthProvider>().clearRole();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      AppAnimations.fadeInRoute(const LoginScreen()),
    );
  }

  void _handleDrawerNavigation(String routeName) {
    final nav = context.read<NavigationProvider>();
    if (routeName == '/admin/home') {
      nav.setIndex(0);
    } else if (routeName == '/admin/bookings') {
      nav.setIndex(1);
    } else if (routeName == '/admin/vendors') {
      nav.setIndex(2);
    } else if (routeName == '/admin/customers') {
      nav.setIndex(3);
    } else if (routeName == '/admin/requests') {
      nav.setIndex(4);
    } else if (routeName == '/admin/inbox') {
      nav.setIndex(5);
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
                  index: nav.currentIndex.clamp(0, 5),
                  children: const [
                    AdminDashboardScreen(),
                    AdminBookingsScreen(),
                    AdminVendorsScreen(),
                    AdminCustomersScreen(),
                    AdminVendorRequestsScreen(),
                    AdminContactInboxScreen(),
                  ],
                ),
              ),
            ],
          ),

          // Floating Bottom Navigation Bar for Admin (Home, Bookings, Vendors, Customers)
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
// Admin Dashboard Body
// ---------------------------------------------------------------------------

class _AdminDashboardBody extends StatelessWidget {
  const _AdminDashboardBody();

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<AdminDashboardProvider>();

    if (dash.isLoading) {
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
            'Admin Dashboard',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time overview of platform performance',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
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
              _StatCard(
                label: 'Total Bookings',
                value: dash.totalBookings.toString(),
                icon: Icons.calendar_month_rounded,
                color: AppColors.brandPink,
              ),
              _StatCard(
                label: 'Pending',
                value: dash.pendingBookings.toString(),
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFE65100),
              ),
              _StatCard(
                label: 'Vendors',
                value: dash.totalVendors.toString(),
                icon: Icons.storefront_rounded,
                color: const Color(0xFF1565C0),
              ),
              _StatCard(
                label: 'Customers',
                value: dash.totalCustomers.toString(),
                icon: Icons.people_rounded,
                color: const Color(0xFF2E7D32),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Revenue chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.lightGrey, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenue Growth',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Rs ${(dash.totalRevenue / 1000).toStringAsFixed(0)}K Total',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 140,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: AppColors.lightGrey, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            getTitlesWidget: (value, _) {
                              const months = [
                                'Jan',
                                'Mar',
                                'May',
                                'Jul',
                                'Sep',
                                'Nov'
                              ];
                              final i = value.toInt();
                              if (i >= 0 && i < months.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(months[i],
                                      style: GoogleFonts.inter(
                                          color: AppColors.textMedium,
                                          fontSize: 10)),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 5,
                      minY: 0,
                      maxY: 6,
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 2),
                            FlSpot(1, 2.8),
                            FlSpot(2, 2.2),
                            FlSpot(3, 4.5),
                            FlSpot(4, 3.8),
                            FlSpot(5, 5.5),
                          ],
                          isCurved: true,
                          color: AppColors.brandPink,
                          barWidth: 3.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.brandPink.withOpacity(0.3),
                                AppColors.brandPink.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recent bookings
          Text(
            'Recent Bookings',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...dash.recentBookings.map((b) {
            final name = b['customerName']?.toString() ??
                (b['customer'] is Map
                    ? b['customer']['name']?.toString()
                    : null) ??
                'Customer';
            final statusStr = b['status']?.toString().trim() ?? '';
            final statusLabel = statusStr.isNotEmpty
                ? '${statusStr[0].toUpperCase()}${statusStr.substring(1)}'
                : 'Pending';
            return _ActivityTile(
              title: name.isNotEmpty ? name : 'Customer',
              subtitle: 'Status: $statusLabel',
              icon: Icons.calendar_month_rounded,
            );
          }),
          if (dash.recentBookings.isEmpty)
            Text(
              'No recent bookings',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textMedium),
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared UI components for Admin screens
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandPink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textWhite, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
