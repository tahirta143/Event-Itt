import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth/vendor_auth_provider.dart';
import '../../providers/vendor/vendor_portal_provider.dart';
import '../../utils/colors/app_colors.dart';
import '../../models/booking/booking_model.dart';

class ChartBucket {
  final String key;
  final String label;
  int bookings;
  double revenue;

  ChartBucket({
    required this.key,
    required this.label,
    this.bookings = 0,
    this.revenue = 0.0,
  });
}

class ServiceBreakdownItem {
  final String name;
  int bookings;
  double revenue;

  ServiceBreakdownItem({
    required this.name,
    this.bookings = 0,
    this.revenue = 0.0,
  });
}

class VendorAnalyticsScreen extends StatefulWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  State<VendorAnalyticsScreen> createState() => _VendorAnalyticsScreenState();
}

class _VendorAnalyticsScreenState extends State<VendorAnalyticsScreen> {
  String _selectedPeriod = '30d';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<VendorAuthProvider>().token ?? '';
      context.read<VendorPortalProvider>().loadStats(token);
      context.read<VendorPortalProvider>().loadBookings(token);
    });
  }

  String _formatPKR(double val) {
    if (val >= 1000000) {
      return 'PKR ${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return 'PKR ${(val / 1000).toStringAsFixed(0)}k';
    }
    return 'PKR ${val.toStringAsFixed(0)}';
  }

  List<ChartBucket> _buildBuckets(String period, List<BookingModel> bookings) {
    final now = DateTime.now();
    DateTime start;
    String mode;

    if (period == '7d') {
      start = DateTime(now.year, now.month, now.day - 6);
      mode = 'day';
    } else if (period == '30d') {
      start = DateTime(now.year, now.month, now.day - 29);
      mode = 'day';
    } else if (period == '90d') {
      start = DateTime(now.year, now.month, now.day - 89);
      mode = 'week';
    } else {
      start = DateTime(now.year, 1, 1);
      mode = 'month';
    }

    final List<ChartBucket> buckets = [];
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    if (mode == 'day') {
      for (var d = start; d.isBefore(now.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
        final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        final label = '${monthNames[d.month - 1]} ${d.day}';
        buckets.add(ChartBucket(key: key, label: label));
      }
    } else if (mode == 'week') {
      var cur = start;
      while (cur.isBefore(now.add(const Duration(days: 7)))) {
        final key = 'w${cur.year}-${cur.month.toString().padLeft(2, '0')}-${cur.day.toString().padLeft(2, '0')}';
        final label = '${monthNames[cur.month - 1]} ${cur.day}';
        buckets.add(ChartBucket(key: key, label: label));
        cur = cur.add(const Duration(days: 7));
      }
    } else {
      for (int m = 1; m <= now.month; m++) {
        final key = '${now.year}-${m.toString().padLeft(2, '0')}';
        final label = monthNames[m - 1];
        buckets.add(ChartBucket(key: key, label: label));
      }
    }

    final inRange = bookings.where((b) {
      final dt = b.createdAt ?? (b.eventDate != null ? DateTime.tryParse(b.eventDate!) : null);
      if (dt == null) return false;
      return dt.isAfter(start.subtract(const Duration(hours: 1))) && dt.isBefore(now.add(const Duration(days: 1)));
    }).toList();

    final Map<String, ChartBucket> bucketMap = {for (var b in buckets) b.key: b};

    for (var b in inRange) {
      final dt = b.createdAt ?? (b.eventDate != null ? DateTime.tryParse(b.eventDate!) : null);
      if (dt == null) continue;

      String bKey;
      if (mode == 'day') {
        bKey = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } else if (mode == 'week') {
        final offset = dt.weekday % 7;
        final weekStart = dt.subtract(Duration(days: offset));
        bKey = 'w${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      } else {
        bKey = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      }

      final bucket = bucketMap[bKey];
      if (bucket != null) {
        bucket.bookings += 1;
        if (b.status.toLowerCase() != 'cancelled') {
          bucket.revenue += (b.estimatedValue ?? b.totalAmount ?? 0.0);
        }
      }
    }

    return buckets;
  }

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<VendorPortalProvider>();
    final vendorAuth = context.watch<VendorAuthProvider>();
    final token = vendorAuth.token ?? '';

    final bookings = portal.bookings;
    final acceptedStatuses = ['confirmed', 'preparing', 'in_progress', 'completed'];

    final now = DateTime.now();
    final days = _selectedPeriod == '7d' ? 7 : _selectedPeriod == '30d' ? 30 : _selectedPeriod == '90d' ? 90 : 365;
    final start = DateTime(now.year, now.month, now.day - (days - 1));

    final inRange = bookings.where((b) {
      final dt = b.createdAt ?? (b.eventDate != null ? DateTime.tryParse(b.eventDate!) : null);
      if (dt == null) return true;
      return dt.isAfter(start.subtract(const Duration(days: 1)));
    }).toList();

    final totalRequests = inRange.isNotEmpty ? inRange.length : bookings.length;
    final confirmedList = inRange.where((b) => acceptedStatuses.contains(b.status.toLowerCase())).toList();
    final confirmedCount = confirmedList.length;
    final conversion = totalRequests > 0 ? ((confirmedCount / totalRequests) * 100).round() : null;

    final revenueTotal = inRange.where((b) => b.status.toLowerCase() != 'cancelled').fold<double>(
          0.0,
          (sum, b) => sum + (b.estimatedValue ?? b.totalAmount ?? 0.0),
        );

    final chartBuckets = _buildBuckets(_selectedPeriod, bookings);

    final Map<String, ServiceBreakdownItem> serviceMap = {};
    for (var b in inRange) {
      final name = b.subcategoryName ?? b.serviceName ?? b.categoryName ?? 'Other Service';
      final item = serviceMap.putIfAbsent(name, () => ServiceBreakdownItem(name: name));
      item.bookings += 1;
      if (b.status.toLowerCase() != 'cancelled') {
        item.revenue += (b.estimatedValue ?? b.totalAmount ?? 0.0);
      }
    }
    final topServices = serviceMap.values.toList()..sort((a, b) => b.revenue.compareTo(a.revenue));

    return portal.isLoading && portal.bookings.isEmpty
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
            ),
          )
        : RefreshIndicator(
            color: AppColors.brandPink,
            onRefresh: () async {
              await portal.loadStats(token);
              await portal.loadBookings(token);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded, color: AppColors.brandPink, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Analytics & Performance',
                        style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'How customers are engaging with your business',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 14),

                  // Time Period Selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        {'key': '7d', 'label': '7 Days'},
                        {'key': '30d', 'label': '30 Days'},
                        {'key': '90d', 'label': '90 Days'},
                        {'key': 'year', 'label': 'This Year'},
                      ].map((p) {
                        final selected = _selectedPeriod == p['key'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(p['label']!),
                            selected: selected,
                            selectedColor: AppColors.brandPink,
                            backgroundColor: AppColors.cardWhite,
                            labelStyle: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                              color: selected ? Colors.white : AppColors.textDark,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: selected ? AppColors.brandPink : AppColors.lightGrey),
                            ),
                            onSelected: (val) => setState(() => _selectedPeriod = p['key']!),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4 Stat Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Booking Requests',
                          value: '$totalRequests',
                          subtitle: 'received this period',
                          icon: Icons.people_alt_outlined,
                          color: AppColors.brandPink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Confirmed Bookings',
                          value: '$confirmedCount',
                          subtitle: 'accepted or completed',
                          icon: Icons.bar_chart_rounded,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Conversion Rate',
                          value: conversion == null ? '—' : '$conversion%',
                          subtitle: 'requests that became confirmed',
                          icon: Icons.percent_rounded,
                          color: AppColors.primaryGold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Estimated Revenue',
                          value: _formatPKR(revenueTotal > 0 ? revenueTotal : portal.totalRevenue),
                          subtitle: 'booking value, excl. cancelled',
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppColors.brandPink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bar Chart 1: Bookings Over Time
                  _buildChartCard(
                    title: 'Bookings over time',
                    icon: Icons.bar_chart_rounded,
                    iconColor: AppColors.brandPink,
                    child: _buildBookingsBarChart(chartBuckets),
                  ),
                  const SizedBox(height: 16),

                  // Bar Chart 2: Estimated Revenue Over Time
                  _buildChartCard(
                    title: 'Estimated revenue over time',
                    icon: Icons.wallet_outlined,
                    iconColor: AppColors.primaryGold,
                    child: _buildRevenueBarChart(chartBuckets),
                  ),
                  const SizedBox(height: 24),

                  // Top Services List
                  Container(
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
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.trending_up_rounded, color: AppColors.brandPink, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Top Services',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Based on requests received this period.",
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.lightGrey),
                        if (topServices.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text('No bookings in this period.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: topServices.take(6).length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.lightGrey),
                            itemBuilder: (context, idx) {
                              final s = topServices[idx];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.brandPink.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${idx + 1}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.brandPink,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.name,
                                            style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                          ),
                                          Text(
                                            '${s.bookings} booking${s.bookings == 1 ? '' : 's'} · ${_formatPKR(s.revenue)}',
                                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMedium, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.textLight),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 190, child: child),
        ],
      ),
    );
  }

  Widget _buildBookingsBarChart(List<ChartBucket> buckets) {
    if (buckets.isEmpty || buckets.every((b) => b.bookings == 0)) {
      return Center(
        child: Text('No bookings in this period.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium, fontStyle: FontStyle.italic)),
      );
    }

    final maxVal = buckets.map((b) => b.bookings).reduce((a, b) => a > b ? a : b).toDouble();
    final maxY = (maxVal == 0 ? 5.0 : (maxVal + 2)).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final b = buckets[groupIndex];
              return BarTooltipItem(
                '${b.label}\nBookings: ${rod.toY.toInt()}',
                GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (val, meta) {
                if (val % 1 == 0 && val >= 0) {
                  return Text('${val.toInt()}', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textLight));
                }
                return const SizedBox();
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx >= 0 && idx < buckets.length) {
                  if (buckets.length > 10 && idx % (buckets.length ~/ 5) != 0) {
                    return const SizedBox();
                  }
                  return Text(buckets[idx].label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textLight));
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.lightGrey, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(buckets.length, (i) {
          final b = buckets[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: b.bookings.toDouble(),
                color: AppColors.brandPink,
                width: 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRevenueBarChart(List<ChartBucket> buckets) {
    if (buckets.isEmpty || buckets.every((b) => b.revenue == 0)) {
      return Center(
        child: Text('No revenue in this period.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium, fontStyle: FontStyle.italic)),
      );
    }

    final maxVal = buckets.map((b) => b.revenue).reduce((a, b) => a > b ? a : b);
    final maxY = (maxVal == 0 ? 10000.0 : (maxVal * 1.2)).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final b = buckets[groupIndex];
              return BarTooltipItem(
                '${b.label}\nRevenue: ${_formatPKR(rod.toY)}',
                GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (val, meta) {
                if (val >= 1000) {
                  return Text('${(val / 1000).toInt()}k', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textLight));
                }
                return Text('${val.toInt()}', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textLight));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx >= 0 && idx < buckets.length) {
                  if (buckets.length > 10 && idx % (buckets.length ~/ 5) != 0) {
                    return const SizedBox();
                  }
                  return Text(buckets[idx].label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textLight));
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.lightGrey, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(buckets.length, (i) {
          final b = buckets[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: b.revenue,
                color: AppColors.primaryGold,
                width: 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }
}
