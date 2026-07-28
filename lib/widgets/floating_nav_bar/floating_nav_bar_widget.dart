import 'package:flutter/material.dart';
import '../../utils/colors/app_colors.dart';

class FloatingNavBarWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 50, right: 50),
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
          children: [
            // Index 0: Home
            _buildNavItem(0, Icons.home_rounded, Icons.home_outlined),
            // Index 1: Dashboard Overview & Analytics
            _buildNavItem(1, Icons.analytics_rounded, Icons.analytics_outlined),
            // Index 2: Services
            _buildNavItem(2, Icons.room_service_rounded, Icons.room_service_outlined),
            // Index 3: Categories & Sub-Categories
            _buildNavItem(3, Icons.category_rounded, Icons.category_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardWhite.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color: isSelected ? AppColors.textWhite : AppColors.textLight,
          size: 22,
        ),
      ),
    );
  }
}
