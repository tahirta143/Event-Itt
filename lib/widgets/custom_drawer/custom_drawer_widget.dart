import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/colors/app_colors.dart';

class CustomDrawerWidget extends StatelessWidget {
  final Function(String routeName) onNavigationSelected;

  const CustomDrawerWidget({
    super.key,
    required this.onNavigationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      backgroundColor: AppColors.cardWhite,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header (#EA4C89)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.brandPink,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=300',
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
                        Text(
                          'VIP Wedding Host',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items List on Clean White Background
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_customize_rounded,
                    title: 'Dashboard Overview & Stats',
                    onTap: () {
                      Navigator.pop(context);
                      onNavigationSelected('/dashboard');
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
                  _buildDrawerItem(
                    icon: Icons.category_rounded,
                    title: 'Categories',
                    onTap: () {
                      Navigator.pop(context);
                      onNavigationSelected('/categories');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.subdirectory_arrow_right_rounded,
                    title: 'Sub-Categories',
                    onTap: () {
                      Navigator.pop(context);
                      onNavigationSelected('/categories');
                    },
                  ),
                  const Divider(color: AppColors.lightGrey, height: 32, thickness: 1),
                  _buildDrawerItem(
                    icon: Icons.favorite_border_rounded,
                    title: 'Saved Venues',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_month_rounded,
                    title: 'My Bookings',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
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
              padding: const EdgeInsets.all(20.0),
              child: ListTile(
                onTap: () {
                  authProvider.logout();
                  Navigator.pop(context);
                  onNavigationSelected('/login');
                },
                leading: const Icon(Icons.logout_rounded, color: AppColors.brandPink),
                title: Text(
                  'Sign Out',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMedium, size: 18),
    );
  }
}

