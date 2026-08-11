import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/auth/admin_auth_provider.dart';
import '../../providers/auth/vendor_auth_provider.dart';
import '../../providers/auth/customer_auth_provider.dart';
import '../../utils/colors/app_colors.dart';

class CustomDrawerWidget extends StatelessWidget {
  final Function(String routeName) onNavigationSelected;

  const CustomDrawerWidget({
    super.key,
    required this.onNavigationSelected,
  });

  String _getBadgeLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '⚡ Admin';
      case UserRole.vendor:
        return '🏪 Vendor';
      case UserRole.customer:
        return '👤 Customer';
      default:
        return '👤 Guest';
    }
  }

  Color _getBadgeColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.brandPink;
      case UserRole.vendor:
        return const Color(0xFF1565C0);
      case UserRole.customer:
        return const Color(0xFF2E7D32);
      default:
        return AppColors.brandPink;
    }
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final role = authProvider.currentRole;
    if (role == UserRole.admin) {
      await context.read<AdminAuthProvider>().logout();
    } else if (role == UserRole.vendor) {
      await context.read<VendorAuthProvider>().logout();
    } else if (role == UserRole.customer) {
      await context.read<CustomerAuthProvider>().logout();
    }
    authProvider.clearRole();
    if (context.mounted) {
      Navigator.pop(context);
      onNavigationSelected('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.currentRole;
    final badgeColor = _getBadgeColor(role);

    return Drawer(
      backgroundColor: AppColors.cardWhite,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.darkHeader,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: badgeColor.withOpacity(0.2),
                    child: Text(
                      authProvider.userName.isNotEmpty
                          ? authProvider.userName[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getBadgeLabel(role),
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (authProvider.userEmail.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            authProvider.userEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                children: [
                  if (role == UserRole.admin) ...[
                    _buildDrawerItem(
                      icon: Icons.dashboard_customize_rounded,
                      title: 'Dashboard Overview',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/admin/home');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.calendar_month_rounded,
                      title: 'Bookings Management',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/admin/bookings');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.storefront_rounded,
                      title: 'Vendors Directory',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/admin/vendors');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.people_rounded,
                      title: 'Customer Accounts',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/admin/customers');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.assignment_turned_in_rounded,
                      title: 'Vendor Requests',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/admin/requests');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.mark_email_unread_rounded,
                      title: 'Contact Inbox',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/admin/inbox');
                      },
                    ),
                  ] else if (role == UserRole.vendor) ...[
                    _buildDrawerItem(
                      icon: Icons.dashboard_rounded,
                      title: 'Vendor Portal Dashboard',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/vendor/home');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.calendar_month_rounded,
                      title: 'Booking Requests',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/vendor/bookings');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.room_service_rounded,
                      title: 'My Listed Services',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/vendor/services');
                      },
                    ),
                  ] else ...[
                    _buildDrawerItem(
                      icon: Icons.home_rounded,
                      title: 'Home & Featured Venues',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/customer/home');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.calendar_month_rounded,
                      title: 'My Bookings',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/customer/bookings');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.category_rounded,
                      title: 'Categories',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/categories');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.room_service_rounded,
                      title: 'Services',
                      onTap: () {
                        Navigator.pop(context);
                        onNavigationSelected('/services');
                      },
                    ),
                  ],
                  const Divider(color: AppColors.lightGrey, height: 32, thickness: 1),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Logout Footer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                onTap: () => _handleLogout(context, authProvider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.brandPink),
                ),
                tileColor: AppColors.brandPink.withOpacity(0.08),
                leading: const Icon(Icons.logout_rounded, color: AppColors.brandPink),
                title: Text(
                  'Sign Out',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandPink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: AppColors.brandPink, size: 22),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMedium, size: 18),
    );
  }
}
