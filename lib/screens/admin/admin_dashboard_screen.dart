import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth/admin_auth_provider.dart';
import '../../providers/admin/admin_dashboard_provider.dart';
import '../../utils/colors/app_colors.dart';
import '../../widgets/dashboard_stat_card/dashboard_stat_card_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();
  String _bookingFilter = 'all';

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _loadData() {
    final token = context.read<AdminAuthProvider>().token ?? '';
    context.read<AdminDashboardProvider>().loadSummary(token);
  }

  String _formatCurrency(dynamic value) {
    final num n = num.tryParse(value?.toString() ?? '0') ?? 0;
    return 'Rs ${n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<AdminDashboardProvider>();
    final adminAuth = context.watch<AdminAuthProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Live Clock & Welcome Widget
          _buildLiveClockHeader(),
          const SizedBox(height: 20),

          if (dash.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
                ),
              ),
            )
          else ...[
            // 2. Today at a Glance
            _buildTodayGlanceSection(dash),
            const SizedBox(height: 20),

            // 3. States Data Cards Grid (Pending, Needs Attention, Pipeline Value, Active Clients)
            _buildStatesDataGrid(dash),
            const SizedBox(height: 20),

            // 4. Date Range & Booking Status Filter Pills Row
            _buildFiltersRow(context, dash, adminAuth.token ?? ''),
            const SizedBox(height: 20),

            // 5. Catalog Metric Cards (Categories, Subcategories, Pipeline Value, Bookings)
            _buildCatalogMetricsGrid(dash),
            const SizedBox(height: 20),

            // 6. Priority Queue & Top Services Row
            _buildPriorityQueueAndTopServices(context, dash, adminAuth.token ?? ''),
            const SizedBox(height: 20),

            // 7. Booking Status Bar Chart (Colors: Gold, Emerald, Red)
            _buildBookingStatusBarChart(dash),
            const SizedBox(height: 20),

            // 8. Event Calendar & Upcoming Events Interactive Section
            const _EventCalendarWidget(),
            const SizedBox(height: 20),

            // 9. Recent Bookings Cards
            _buildRecentBookingsSection(context, dash, adminAuth.token ?? ''),
            const SizedBox(height: 100),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Live Clock Header Widget
  // ---------------------------------------------------------------------------
  Widget _buildLiveClockHeader() {
    final timeStr =
        '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}';
    final dateStr =
        '${_currentTime.day}/${_currentTime.month}/${_currentTime.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live System Dashboard',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                dateStr,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome to EVENTITT Admin!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Real-time analytics & bookings monitoring',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textMedium),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_outlined,
                      size: 16, color: AppColors.brandPink),
                  const SizedBox(width: 4),
                  Text(
                    timeStr,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandPink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Today at a Glance
  // ---------------------------------------------------------------------------
  Widget _buildTodayGlanceSection(AdminDashboardProvider dash) {
    final today = dash.todayBookings;
    final todayTotal = today['total'] ?? 0;
    final todayValue = today['value'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TODAY AT A GLANCE',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            DashboardStatCardWidget(
              title: "Today's Events",
              value: '$todayTotal',
              changePercentage: _formatCurrency(todayValue),
              icon: Icons.calendar_today_outlined,
            ),
            DashboardStatCardWidget(
              title: 'Upcoming 7 Days',
              value: '${dash.upcomingCount}',
              changePercentage: '7 Days',
              icon: Icons.calendar_month_outlined,
            ),
            DashboardStatCardWidget(
              title: 'Overdue Follow-up',
              value: '${dash.overdueCount}',
              changePercentage: 'Action',
              icon: Icons.warning_amber_outlined,
            ),
            DashboardStatCardWidget(
              title: 'Pending Bookings',
              value: '${dash.pendingBookings}',
              changePercentage: 'Pending',
              icon: Icons.notifications_active_outlined,
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. States Data Cards Grid
  // ---------------------------------------------------------------------------
  Widget _buildStatesDataGrid(AdminDashboardProvider dash) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        DashboardStatCardWidget(
          title: 'Pending Bookings',
          value: '${dash.pendingBookings}',
          changePercentage: 'Active',
          icon: Icons.hourglass_top_outlined,
        ),
        DashboardStatCardWidget(
          title: 'Needs Attention',
          value: '${dash.needsAttention.length}',
          changePercentage: 'Alert',
          icon: Icons.notification_important_outlined,
        ),
        DashboardStatCardWidget(
          title: 'Pipeline Value',
          value: _formatCurrency(dash.pipelineValue),
          changePercentage: 'Estimated',
          icon: Icons.monetization_on_outlined,
        ),
        DashboardStatCardWidget(
          title: 'Active Clients',
          value: '${dash.customersWithBookings}',
          changePercentage: 'Clients',
          icon: Icons.people_alt_outlined,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Date Range & Booking Status Filter Pills Row
  // ---------------------------------------------------------------------------
  Widget _buildFiltersRow(
      BuildContext context, AdminDashboardProvider dash, String token) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...[
            {'val': 'today', 'lbl': 'Today'},
            {'val': '7days', 'lbl': '7 Days'},
            {'val': '30days', 'lbl': '30 Days'}
          ].map((opt) {
            final isSel = dash.range == opt['val'];
            return GestureDetector(
              onTap: () => dash.setRange(token, opt['val']!),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.brandPink : AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isSel ? AppColors.brandPink : AppColors.lightGrey),
                ),
                child: Text(
                  opt['lbl']!,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    color: isSel ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 12),
          ...['all', 'pending', 'confirmed', 'cancelled'].map((st) {
            final isSel = _bookingFilter == st;
            return GestureDetector(
              onTap: () => setState(() => _bookingFilter = st),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSel
                      ? AppColors.textDark
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Text(
                  st.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    color: isSel ? Colors.white : AppColors.textMedium,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Catalog Metric Cards
  // ---------------------------------------------------------------------------
  Widget _buildCatalogMetricsGrid(AdminDashboardProvider dash) {
    final cat = dash.categories;
    final sub = dash.subcategories;
    final bks = dash.bookings;

    return Column(
      children: [
        _buildMetricRow('Categories', cat['total'] ?? 0, cat['active'] ?? 0,
            cat['inactive'] ?? 0),
        const SizedBox(height: 8),
        _buildMetricRow('Subcategories', sub['total'] ?? 0, sub['active'] ?? 0,
            sub['inactive'] ?? 0),
        const SizedBox(height: 8),
        _buildPipelineMetricRow(dash),
        const SizedBox(height: 8),
        _buildMetricRow('Bookings', bks['total'] ?? 0, bks['confirmed'] ?? 0,
            bks['pending'] ?? 0),
      ],
    );
  }

  Widget _buildPipelineMetricRow(AdminDashboardProvider dash) {
    final gross = dash.pipelineGross;
    final paid = dash.pipelinePaid;
    final outstanding = dash.pipelineOutstanding;
    final pct = gross > 0 ? ((paid / gross) * 100).round().clamp(0, 100) : 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pipeline Value',
                  style: GoogleFonts.montserrat(
                      fontSize: 12, fontWeight: FontWeight.bold)),
              Text(_formatCurrency(outstanding),
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: gross > 0 ? (paid / gross).clamp(0.0, 1.0) : 0,
              minHeight: 6,
              backgroundColor: AppColors.lightGrey,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.successGreen),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Paid: ${_formatCurrency(paid)} ($pct%)',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold)),
              Text('Gross: ${_formatCurrency(gross)}',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String title, int total, int active, int inactive) {
    final pct = total > 0 ? (active / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: GoogleFonts.montserrat(
                      fontSize: 12, fontWeight: FontWeight.bold)),
              Text('$total Total',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textMedium)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? (active / total) : 0,
              minHeight: 6,
              backgroundColor: Colors.red.withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.successGreen),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$active Active ($pct%)',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold)),
              Text('$inactive Inactive',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Priority Queue & Top Services Row
  // ---------------------------------------------------------------------------
  Widget _buildPriorityQueueAndTopServices(
      BuildContext context, AdminDashboardProvider dash, String token) {
    final priorityItems = dash.needsAttention;
    final topServicesItems = dash.topServices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Priority Queue Card
        Container(
          padding: const EdgeInsets.all(16),
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
                  Text('Priority Queue (Follow-up Needed)',
                      style: GoogleFonts.montserrat(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${priorityItems.length} Pending',
                      style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (priorityItems.isEmpty)
                Text('No priority items pending action.',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textMedium))
              else
                ...priorityItems.take(3).map((item) {
                  final b = item as Map<String, dynamic>;
                  final id = b['id']?.toString() ?? '';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                b['customer_name']?.toString() ?? 'Customer',
                                style: GoogleFonts.montserrat(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              b['event_date']?.toString().split('T')[0] ?? '',
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: AppColors.textLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${b['service_name'] ?? ''} › ${b['subcategory_name'] ?? ''}',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textMedium),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.successGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => dash.updateBookingStatus(
                                    token, id, 'confirmed'),
                                icon: const Icon(Icons.check_outlined, size: 14),
                                label: const Text('Confirm',
                                    style: TextStyle(fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => dash.updateBookingStatus(
                                    token, id, 'cancelled'),
                                icon: const Icon(Icons.close_outlined, size: 14),
                                label: const Text('Cancel',
                                    style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Top Services Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Top Booked Services',
                  style: GoogleFonts.montserrat(
                      fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (topServicesItems.isEmpty)
                Text('No service booking counts available yet.',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textMedium))
              else
                ...topServicesItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.brandPink.withOpacity(0.12),
                          child: Text(
                            '${idx + 1}',
                            style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brandPink),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['subcategory_name']?.toString() ?? '',
                                style: GoogleFonts.montserrat(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                item['service_name']?.toString() ?? '',
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: AppColors.textMedium),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item['booking_count'] ?? 0} bookings',
                          style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Booking Status Bar Chart (Colors: Gold, Emerald, Red matching React)
  // ---------------------------------------------------------------------------
  Widget _buildBookingStatusBarChart(AdminDashboardProvider dash) {
    final chartData = dash.bookingChartData;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Status Breakdown',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),

          // Legend
          Row(
            children: [
              _buildChartLegendItem('Pending', AppColors.primaryGold),
              const SizedBox(width: 12),
              _buildChartLegendItem('Confirmed', AppColors.successGreen),
              const SizedBox(width: 12),
              _buildChartLegendItem('Cancelled', Colors.red),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 180,
            child: chartData.isEmpty
                ? Center(
                    child: Text('No chart data available for selected range.',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textMedium)),
                  )
                : BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppColors.lightGrey,
                          strokeWidth: 1,
                        ),
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
                            reservedSize: 26,
                            getTitlesWidget: (value, _) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < chartData.length) {
                                final dStr =
                                    chartData[idx]['date']?.toString() ?? '';
                                final shortDate = _formatDateWithMonth(dStr);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    shortDate,
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: chartData.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value as Map<String, dynamic>;
                        final p =
                            double.tryParse(item['pending']?.toString() ?? '0') ??
                                0;
                        final c = double.tryParse(
                                item['confirmed']?.toString() ?? '0') ??
                            0;
                        final r = double.tryParse(
                                item['cancelled']?.toString() ?? '0') ??
                            0;

                        return BarChartGroupData(
                          x: idx,
                          barRods: [
                            BarChartRodData(
                                toY: p,
                                color: AppColors.primaryGold,
                                width: 8,
                                borderRadius: BorderRadius.circular(2)),
                            BarChartRodData(
                                toY: c,
                                color: AppColors.successGreen,
                                width: 8,
                                borderRadius: BorderRadius.circular(2)),
                            BarChartRodData(
                                toY: r,
                                color: Colors.red,
                                width: 8,
                                borderRadius: BorderRadius.circular(2)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDateWithMonth(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(rawDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return rawDate;
    }
  }

  Widget _buildChartLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 9. Recent Bookings Cards
  // ---------------------------------------------------------------------------
  Widget _buildRecentBookingsSection(
      BuildContext context, AdminDashboardProvider dash, String token) {
    final items = dash.recentBookings;

    final filtered = items.where((b) {
      final map = b as Map<String, dynamic>;
      final st = map['status']?.toString().toLowerCase() ?? '';
      if (_bookingFilter == 'all') return true;
      if (_bookingFilter == 'needs_attention') return st == 'pending';
      return st == _bookingFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Bookings',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Center(
              child: Text('No recent bookings match filter.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textMedium)),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final b = filtered[index] as Map<String, dynamic>;
              final id = b['id']?.toString() ?? '';
              final name = b['customer_name']?.toString() ??
                  b['customerName']?.toString() ??
                  'Customer';
              final subName = b['subcategory_name']?.toString() ?? '';
              final srvName = b['service_name']?.toString() ?? '';
              final status = b['status']?.toString() ?? 'pending';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: status == 'confirmed'
                                ? AppColors.successGreen.withOpacity(0.12)
                                : status == 'cancelled'
                                    ? Colors.red.withOpacity(0.12)
                                    : AppColors.primaryGold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: status == 'confirmed'
                                  ? AppColors.successGreen
                                  : status == 'cancelled'
                                      ? Colors.red
                                      : AppColors.primaryGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (srvName.isNotEmpty || subName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$srvName ${subName.isNotEmpty ? '› $subName' : ''}',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textMedium),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.successGreen,
                              side: const BorderSide(color: AppColors.successGreen),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            onPressed: () => dash.updateBookingStatus(
                                token, id, 'confirmed'),
                            icon: const Icon(Icons.check_outlined, size: 14),
                            label: const Text('Confirm',
                                style: TextStyle(fontSize: 11)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            onPressed: () => dash.updateBookingStatus(
                                token, id, 'cancelled'),
                            icon: const Icon(Icons.close_outlined, size: 14),
                            label: const Text('Cancel',
                                style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Event Calendar & Upcoming Events Interactive Widget
// ---------------------------------------------------------------------------

class _EventCalendarWidget extends StatefulWidget {
  const _EventCalendarWidget();

  @override
  State<_EventCalendarWidget> createState() => _EventCalendarWidgetState();
}

class _EventCalendarWidgetState extends State<_EventCalendarWidget> {
  DateTime _viewDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  String? _selectedKey;

  static const List<String> _weekdays = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT'
  ];
  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _selectedKey = _toKey(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCalendarData());
  }

  String _toKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _fetchCalendarData() {
    final token = context.read<AdminAuthProvider>().token ?? '';
    final start = DateTime(_viewDate.year, _viewDate.month - 1, 26);
    final end = DateTime(_viewDate.year, _viewDate.month + 2, 5);
    context
        .read<AdminDashboardProvider>()
        .loadCalendar(token, _toKey(start), _toKey(end));
  }

  void _navigateMonth(int delta) {
    setState(() {
      _viewDate = DateTime(_viewDate.year, _viewDate.month + delta, 1);
    });
    _fetchCalendarData();
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _viewDate = DateTime(now.year, now.month, 1);
      _selectedKey = _toKey(now);
    });
    _fetchCalendarData();
  }

  Color _statusDotColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return AppColors.successGreen;
      case 'pending':
        return AppColors.primaryGold;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.brandPink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<AdminDashboardProvider>();
    final year = _viewDate.year;
    final month = _viewDate.month;
    final monthTitle = '${_monthNames[month - 1]} $year';

    final firstDayOfWeek = DateTime(year, month, 1).weekday % 7;

    final List<Map<String, dynamic>> cells = [];
    for (int i = 0; i < 35; i++) {
      final date = DateTime(year, month, i - firstDayOfWeek + 1);
      cells.add({
        'date': date,
        'day': date.day,
        'inMonth': date.month == month,
        'key': _toKey(date),
      });
    }

    final selectedEvents =
        _selectedKey != null ? (dash.eventsByDate[_selectedKey] ?? []) : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Calendar Box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Header Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Event Calendar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_outlined, size: 20),
                          onPressed: () => _navigateMonth(-1),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        Text(
                          monthTitle,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_outlined, size: 20),
                          onPressed: () => _navigateMonth(1),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _goToday,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.brandPink.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Today',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brandPink,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Weekday Labels Header Row
              Row(
                children: _weekdays
                    .map(
                      (w) => Expanded(
                        child: Center(
                          child: Text(
                            w,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),

              // Month Days Grid
              if (dash.isLoadingCalendar)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.brandPink),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: cells.length,
                  itemBuilder: (ctx, idx) {
                    final cell = cells[idx];
                    final String key = cell['key'];
                    final bool inMonth = cell['inMonth'];
                    final bool isToday = key == _toKey(DateTime.now());
                    final bool isSelected = key == _selectedKey;
                    final dayEvents = dash.eventsByDate[key] ?? [];

                    return GestureDetector(
                      onTap: () => setState(() => _selectedKey = key),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandPink.withOpacity(0.15)
                              : isToday
                                  ? AppColors.lightBackground
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandPink
                                : isToday
                                    ? AppColors.brandPink.withOpacity(0.4)
                                    : AppColors.lightGrey.withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${cell['day']}',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: !inMonth
                                    ? AppColors.textLight.withOpacity(0.4)
                                    : isSelected
                                        ? AppColors.brandPink
                                        : AppColors.textDark,
                              ),
                            ),
                            if (inMonth && dayEvents.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: dayEvents.take(3).map((e) {
                                  final st = e['status']?.toString();
                                  return Container(
                                    width: 4,
                                    height: 4,
                                    margin:
                                        const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: BoxDecoration(
                                      color: _statusDotColor(st),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 16),

              // Selected Date Bookings List
              if (_selectedKey != null) ...[
                Text(
                  'Bookings on $_selectedKey (${selectedEvents.length})',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                if (selectedEvents.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'No bookings on this date.',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.textMedium),
                    ),
                  )
                else
                  ...selectedEvents.map((e) {
                    final cName = e['customer_name']?.toString() ?? 'Customer';
                    final sName = e['service_name']?.toString() ?? '';
                    final subName = e['subcategory_name']?.toString() ?? '';
                    final status = e['status']?.toString() ?? 'pending';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cName,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$sName › $subName',
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppColors.textMedium),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusDotColor(status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _statusDotColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Upcoming Events Cards Section
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Events',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Next 10 Events',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textMedium),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (dash.upcomingEvents.isEmpty)
                Text('No upcoming events scheduled.',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textMedium))
              else
                ...dash.upcomingEvents.map((e) {
                  final rawDate = e['event_date']?.toString().split('T')[0] ?? '';
                  String monthStr = 'AUG';
                  String dayStr = '12';
                  if (rawDate.contains('-')) {
                    final parts = rawDate.split('-');
                    if (parts.length >= 3) {
                      dayStr = parts[2];
                      final m = int.tryParse(parts[1]) ?? 8;
                      const mList = [
                        'JAN',
                        'FEB',
                        'MAR',
                        'APR',
                        'MAY',
                        'JUN',
                        'JUL',
                        'AUG',
                        'SEP',
                        'OCT',
                        'NOV',
                        'DEC'
                      ];
                      monthStr = mList[(m - 1).clamp(0, 11)];
                    }
                  }
                  final cName = e['customer_name']?.toString() ?? 'Customer';
                  final sName = e['service_name']?.toString() ?? '';
                  final subName = e['subcategory_name']?.toString() ?? '';
                  final status = e['status']?.toString() ?? 'pending';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.brandPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                monthStr,
                                style: GoogleFonts.montserrat(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brandPink,
                                ),
                              ),
                              Text(
                                dayStr,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cName,
                                style: GoogleFonts.montserrat(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$sName › $subName',
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: AppColors.textMedium),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: status == 'confirmed'
                                ? AppColors.successGreen.withOpacity(0.12)
                                : status == 'cancelled'
                                    ? Colors.red.withOpacity(0.12)
                                    : AppColors.primaryGold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: status == 'confirmed'
                                  ? AppColors.successGreen
                                  : status == 'cancelled'
                                      ? Colors.red
                                      : AppColors.primaryGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}
