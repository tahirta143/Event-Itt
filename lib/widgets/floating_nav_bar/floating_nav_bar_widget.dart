import 'package:flutter/material.dart';
import '../../utils/colors/app_colors.dart';

class FloatingNavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const FloatingNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    this.label = '',
  });
}

class FloatingNavBarWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNavItem>? items;

  const FloatingNavBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  });

  static const List<FloatingNavItem> _defaultItems = [
    FloatingNavItem(
      activeIcon: Icons.home_outlined,
      inactiveIcon: Icons.home_outlined,
      label: 'Home',
    ),
    FloatingNavItem(
      activeIcon: Icons.analytics_outlined,
      inactiveIcon: Icons.analytics_outlined,
      label: 'Analytics',
    ),
    FloatingNavItem(
      activeIcon: Icons.room_service_outlined,
      inactiveIcon: Icons.room_service_outlined,
      label: 'Services',
    ),
    FloatingNavItem(
      activeIcon: Icons.category_outlined,
      inactiveIcon: Icons.category_outlined,
      label: 'Categories',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final navItems = items ?? _defaultItems;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 40, right: 40),
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.darkHeader,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(navItems.length, (i) {
            final item = navItems[i];
            final isSelected = currentIndex == i;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.inactiveIcon,
                  color: isSelected ? Colors.white : Colors.white60,
                  size: 22,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
