import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/vendor_auth_provider.dart';
import '../../providers/vendor/vendor_availability_provider.dart';
import '../../models/booking/booking_model.dart';
import '../../utils/colors/app_colors.dart';

class VendorAvailabilityScreen extends StatefulWidget {
  const VendorAvailabilityScreen({super.key});

  @override
  State<VendorAvailabilityScreen> createState() => _VendorAvailabilityScreenState();
}

class _VendorAvailabilityScreenState extends State<VendorAvailabilityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<VendorAuthProvider>().token ?? '';
      context.read<VendorAvailabilityProvider>().fetchAvailability(token);
    });
  }

  void _showDateActionSheet(
    DateTime date,
    String dateStr,
    bool isBlackout,
    List<BookingModel> bookingsForDay,
    String token,
  ) {
    final reasonController = TextEditingController();
    final availProv = context.read<VendorAvailabilityProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day Details',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMedium),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: $dateStr',
                  style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.brandPink),
                ),
                const SizedBox(height: 16),

                // Status Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBlackout
                        ? Colors.red.withValues(alpha: 0.1)
                        : (bookingsForDay.isNotEmpty ? AppColors.brandPink.withValues(alpha: 0.1) : AppColors.successGreen.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isBlackout
                          ? Colors.red.withValues(alpha: 0.3)
                          : (bookingsForDay.isNotEmpty ? AppColors.brandPink.withValues(alpha: 0.3) : AppColors.successGreen.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: Text(
                    isBlackout
                        ? 'Unavailable — marked as blocked date.'
                        : bookingsForDay.isNotEmpty
                            ? 'Booked — ${bookingsForDay.length} event booking(s) assigned.'
                            : 'Available for new client assignments.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isBlackout
                          ? Colors.red
                          : (bookingsForDay.isNotEmpty ? AppColors.brandPink : AppColors.successGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Assigned Bookings List for this Day
                if (bookingsForDay.isNotEmpty) ...[
                  Text(
                    'Bookings on this date',
                    style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Column(
                      children: bookingsForDay.map((b) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.brandPink.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.event_seat_rounded, color: AppColors.brandPink, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.subcategoryName ?? b.serviceName ?? 'Event Booking',
                                      style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                    ),
                                    Text(
                                      '${b.customerName ?? 'Customer'} · ${b.guestCount ?? 0} guests · Rs ${(b.estimatedValue ?? b.totalAmount ?? 0).toStringAsFixed(0)}',
                                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.successGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  b.statusLabel,
                                  style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Blackout toggle actions
                if (isBlackout) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok = await availProv.removeBlackout(token, dateStr);
                        if (ok && mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Restored availability for $dateStr')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Mark Available Again', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: 'Add Note / Reason (optional)',
                      hintText: 'e.g. Vacation, offline full booking, maintenance…',
                      labelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok = await availProv.createBlackout(token, dateStr, reason: reasonController.text.trim());
                        if (ok && mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Marked $dateStr as unavailable')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Mark Unavailable', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availProv = context.watch<VendorAvailabilityProvider>();
    final vendorAuth = context.watch<VendorAuthProvider>();
    final token = vendorAuth.token ?? '';

    final currentMonth = availProv.currentMonth;
    final year = currentMonth.year;
    final month = currentMonth.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return availProv.isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
            ),
          )
        : RefreshIndicator(
            color: AppColors.brandPink,
            onRefresh: () => availProv.fetchAvailability(token),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, color: AppColors.brandPink, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Availability & Calendar',
                                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Block dates you cannot accept bookings',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.today, color: AppColors.brandPink),
                        tooltip: 'Go to today',
                        onPressed: () => availProv.goToToday(token),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Month Navigator Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: AppColors.brandPink),
                          onPressed: () => availProv.changeMonth(-1, token),
                        ),
                        Text(
                          '${monthNames[month - 1]} $year',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: AppColors.brandPink),
                          onPressed: () => availProv.changeMonth(1, token),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Calendar Grid Card
                  Container(
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
                      children: [
                        // Weekday labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                            return SizedBox(
                              width: 38,
                              child: Center(
                                child: Text(
                                  day,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppColors.lightGrey),
                        const SizedBox(height: 10),

                        // Days Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 42,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 6,
                            childAspectRatio: 0.9,
                          ),
                          itemBuilder: (context, index) {
                            final dayNumber = index - startingWeekday + 1;
                            if (dayNumber < 1 || dayNumber > daysInMonth) {
                              return const SizedBox();
                            }

                            final date = DateTime(year, month, dayNumber);
                            final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                            final isBlackout = availProv.blackoutDates.containsKey(dateKey);
                            final dayBookingsList = availProv.dayBookings[dateKey] ?? [];
                            final hasBooking = dayBookingsList.isNotEmpty || availProv.calendarBookings.containsKey(dateKey);

                            return InkWell(
                              onTap: () => _showDateActionSheet(date, dateKey, isBlackout, dayBookingsList, token),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isBlackout
                                      ? Colors.red.withValues(alpha: 0.12)
                                      : (hasBooking ? AppColors.brandPink.withValues(alpha: 0.12) : AppColors.lightBackground),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isBlackout
                                        ? Colors.red.withValues(alpha: 0.5)
                                        : (hasBooking ? AppColors.brandPink : Colors.transparent),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$dayNumber',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isBlackout
                                            ? Colors.red
                                            : (hasBooking ? AppColors.brandPink : AppColors.textDark),
                                      ),
                                    ),
                                    if (hasBooking) ...[
                                      const SizedBox(height: 2),
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                          color: AppColors.brandPink,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ] else if (isBlackout) ...[
                                      const SizedBox(height: 2),
                                      const Icon(Icons.block, size: 8, color: Colors.red),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Legend
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem(AppColors.brandPink, 'Booked'),
                        _buildLegendItem(Colors.red, 'Unavailable'),
                        _buildLegendItem(AppColors.lightGrey, 'Available'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
