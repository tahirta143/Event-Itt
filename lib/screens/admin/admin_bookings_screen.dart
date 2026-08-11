import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/admin_auth_provider.dart';
import '../../providers/admin/admin_bookings_provider.dart';
import '../../models/booking/booking_model.dart';
import '../../utils/colors/app_colors.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final token = context.read<AdminAuthProvider>().token ?? '';
    context.read<AdminBookingsProvider>().loadBookings(token);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFE65100);
      case 'in_progress':
      case 'preparing':
        return const Color(0xFF1565C0);
      case 'completed':
        return const Color(0xFF6A1B9A);
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textMedium;
    }
  }

  void _showBookingDetail(BuildContext context, BookingModel booking) {
    final adminAuth = context.read<AdminAuthProvider>();
    final provider = context.read<AdminBookingsProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.id}',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (booking.serviceName != null)
              Text(
                booking.serviceName!,
                style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandPink),
              ),
            if (booking.customerName != null)
              Text(
                'Customer: ${booking.customerName}',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textDark),
              ),
            if (booking.vendorName != null)
              Text(
                'Vendor: ${booking.vendorName}',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textMedium),
              ),
            if (booking.eventDate != null)
              Text(
                'Event Date: ${booking.eventDate}',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textLight),
              ),
            if (booking.totalAmount != null) ...[
              const SizedBox(height: 8),
              Text(
                'Amount: Rs ${booking.totalAmount!.toStringAsFixed(0)}',
                style: GoogleFonts.montserrat(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
            const Divider(height: 24),

            Text(
              'Update Status:',
              style: GoogleFonts.montserrat(
                  fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['confirmed', 'preparing', 'in_progress', 'completed', 'cancelled']
                  .map((st) => ActionChip(
                        label: Text(st.toUpperCase()),
                        backgroundColor: _statusColor(st).withOpacity(0.12),
                        labelStyle: TextStyle(
                            color: _statusColor(st),
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        onPressed: () async {
                          final err = await provider.updateStatus(
                              adminAuth.token ?? '', booking.id, st);
                          if (context.mounted) {
                            Navigator.pop(context);
                            if (err != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(err)),
                              );
                            }
                          }
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminBookingsProvider>();
    final adminAuth = context.watch<AdminAuthProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    'Bookings Management',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Showing ${provider.bookings.length} of ${provider.totalCount} total bookings',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textMedium),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Box
          TextField(
            controller: _searchController,
            onChanged: (val) => provider.loadBookings(
              adminAuth.token ?? '',
              search: val,
              page: 1,
            ),
            decoration: InputDecoration(
              hintText: 'Search by ID, customer, or service...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.lightGrey),
              ),
              filled: true,
              fillColor: AppColors.cardWhite,
            ),
          ),
          const SizedBox(height: 12),

          // Status Filters Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, provider, '', 'All Statuses'),
                _buildFilterChip(context, provider, 'pending', 'Pending'),
                _buildFilterChip(context, provider, 'confirmed', 'Confirmed'),
                _buildFilterChip(context, provider, 'preparing', 'Preparing'),
                _buildFilterChip(context, provider, 'in_progress', 'In Progress'),
                _buildFilterChip(context, provider, 'completed', 'Completed'),
                _buildFilterChip(context, provider, 'cancelled', 'Cancelled'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
                ),
              ),
            )
          else if (provider.bookings.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Column(
                children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 48, color: AppColors.textLight),
                  const SizedBox(height: 12),
                  Text(
                    'No bookings found',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.bookings.length,
              itemBuilder: (context, index) {
                final booking = provider.bookings[index];
                return GestureDetector(
                  onTap: () => _showBookingDetail(context, booking),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.lightGrey),
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Booking #${booking.id}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(booking.status)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                booking.statusLabel,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _statusColor(booking.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (booking.serviceName != null)
                          Text(
                            booking.serviceName!,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandPink,
                            ),
                          ),
                        if (booking.customerName != null)
                          Text(
                            'Customer: ${booking.customerName}',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textMedium),
                          ),
                        if (booking.vendorName != null)
                          Text(
                            'Vendor: ${booking.vendorName}',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: AppColors.textLight),
                          ),
                        if (booking.totalAmount != null &&
                            booking.totalAmount! > 0) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Rs ${booking.totalAmount!.toStringAsFixed(0)}',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

          // Pagination Controls
          if (provider.totalPages > 1) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: provider.currentPage > 1
                      ? () => provider.prevPage(adminAuth.token ?? '')
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Previous'),
                ),
                Text(
                  'Page ${provider.currentPage} of ${provider.totalPages}',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: provider.currentPage < provider.totalPages
                      ? () => provider.nextPage(adminAuth.token ?? '')
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  label: const Text('Next'),
                ),
              ],
            ),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    AdminBookingsProvider provider,
    String value,
    String label,
  ) {
    final isSelected = provider.statusFilter == value;
    return GestureDetector(
      onTap: () {
        final token = context.read<AdminAuthProvider>().token ?? '';
        provider.loadBookings(token, status: value, page: 1);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPink : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandPink : AppColors.lightGrey,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
