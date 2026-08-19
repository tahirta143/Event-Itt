import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dashboard/dashboard_stat_model.dart';
import '../../utils/colors/app_colors.dart';

class DashboardStatCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String? changePercentage;
  final IconData icon;
  final Color? color;

  const DashboardStatCardWidget({
    super.key,
    required this.title,
    required this.value,
    this.changePercentage,
    required this.icon,
    this.color,
  });

  factory DashboardStatCardWidget.fromModel(DashboardStatModel model) {
    return DashboardStatCardWidget(
      title: model.title,
      value: model.value,
      changePercentage: model.changePercentage,
      icon: model.icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.brandPink;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGrey, width: 1.2),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.textDark.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.textDark, size: 16),
              ),
              if (changePercentage != null && changePercentage!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    changePercentage!,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
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
