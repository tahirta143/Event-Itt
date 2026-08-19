import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors/app_colors.dart';

/// Pill-style 3-tab role selector for the Login screen.
///
/// Tabs: Admin | Vendor | Customer
/// Uses the existing [AppColors] palette (brandPink, champagne, etc.)
class RoleTabSelectorWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  static const List<_TabConfig> _tabs = [
    _TabConfig(label: 'Admin', icon: Icons.admin_panel_settings_outlined),
    _TabConfig(label: 'Vendor', icon: Icons.storefront_outlined),
    _TabConfig(label: 'Customer', icon: Icons.person_outline_outlined),
  ];

  const RoleTabSelectorWidget({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.brandPink
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.brandPink.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _tabs[i].icon,
                      size: 18,
                      color: isSelected
                          ? AppColors.textWhite
                          : AppColors.champagne.withOpacity(0.75),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _tabs[i].label,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.textWhite
                            : AppColors.champagne.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabConfig {
  final String label;
  final IconData icon;
  const _TabConfig({required this.label, required this.icon});
}
