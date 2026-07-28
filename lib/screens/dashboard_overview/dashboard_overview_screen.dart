import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard/dashboard_provider.dart';
import '../../utils/colors/app_colors.dart';
import '../../widgets/dashboard_stat_card/dashboard_stat_card_widget.dart';

class DashboardOverviewScreen extends StatefulWidget {
  const DashboardOverviewScreen({super.key});

  @override
  State<DashboardOverviewScreen> createState() => _DashboardOverviewScreenState();
}

class _DashboardOverviewScreenState extends State<DashboardOverviewScreen> {
  int _selectedPeriodIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Subtitle
          Text(
            'Dashboard Overview & Analytics',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time overview of venue bookings & performance',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 16),

          // Compact 2x2 Grid of Stat Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: dashboardProvider.stats.length,
            itemBuilder: (context, index) {
              final stat = dashboardProvider.stats[index];
              return DashboardStatCardWidget(stat: stat);
            },
          ),
          const SizedBox(height: 24),

          // FL Chart Section - Revenue & Booking Performance Line Chart (White Card with #EA4C89 Line)
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
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
                        const SizedBox(height: 2),
                        Text(
                          '\$ 4,800,000 Total Value',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Period Filter Selector
                    Row(
                      children: ['6M', '1Y'].asMap().entries.map((entry) {
                        final isSelected = _selectedPeriodIndex == entry.key;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPeriodIndex = entry.key;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.brandPink : AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              entry.value,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.textWhite : AppColors.textDark,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Interactive FL Chart Widget
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.lightGrey,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) {
                              const months = ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'];
                              final index = value.toInt();
                              if (index >= 0 && index < months.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    months[index],
                                    style: GoogleFonts.inter(
                                      color: AppColors.textMedium,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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

          // Recent Activity Section
          Text(
            'Recent Booking Requests',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          _buildActivityTile('Luxury Palace Venue Reserved', 'Udaipur, Rajasthan • Today', Icons.check_circle_rounded),
          _buildActivityTile('Inquiry Sent to Royal Catering', 'Pending response • Yesterday', Icons.hourglass_top_rounded),
          _buildActivityTile('Cinematic Photography Quotation', 'Approved • 3 days ago', Icons.task_alt_rounded),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildActivityTile(String title, String subtitle, IconData icon) {
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
