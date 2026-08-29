import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/vendor_auth_provider.dart';
import '../../providers/vendor/vendor_portal_provider.dart';
import '../../utils/colors/app_colors.dart';
import '../../models/booking/booking_model.dart';

class VendorBookingsScreen extends StatefulWidget {
  const VendorBookingsScreen({super.key});

  @override
  State<VendorBookingsScreen> createState() => _VendorBookingsScreenState();
}

class _VendorBookingsScreenState extends State<VendorBookingsScreen> {
  String _selectedStatusFilter = 'all';
  String _searchQuery = '';

  final List<String> _filterOptions = [
    'all',
    'pending',
    'confirmed',
    'preparing',
    'in_progress',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<VendorAuthProvider>().token ?? '';
      context.read<VendorPortalProvider>().loadBookings(token);
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return AppColors.successGreen;
      case 'pending': return AppColors.discountOrange;
      case 'preparing': return AppColors.brandPink;
      case 'in_progress': return Colors.purple;
      case 'completed': return AppColors.primaryGold;
      case 'cancelled': return Colors.red;
      default: return AppColors.textMedium;
    }
  }

  String _nextStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'confirmed';
      case 'confirmed': return 'preparing';
      case 'preparing': return 'in_progress';
      case 'in_progress': return 'completed';
      default: return '';
    }
  }

  String _nextStatusActionLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Accept Booking';
      case 'confirmed': return 'Start Preparing';
      case 'preparing': return 'Mark In Progress';
      case 'in_progress': return 'Mark Completed';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<VendorPortalProvider>();
    final vendorAuth = context.watch<VendorAuthProvider>();
    final token = vendorAuth.token ?? '';

    List<BookingModel> bookings = portal.bookings;

    if (_selectedStatusFilter != 'all') {
      bookings = bookings.where((b) => b.status.toLowerCase() == _selectedStatusFilter).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      bookings = bookings.where((b) {
        return (b.customerName?.toLowerCase().contains(q) ?? false) ||
            (b.serviceName?.toLowerCase().contains(q) ?? false) ||
            (b.id.toLowerCase().contains(q));
      }).toList();
    }

    return Column(
      children: [
        // Search & Filter header
        Container(
          color: AppColors.lightBackground,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            children: [
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'Search by client or service...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textLight),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.brandPink, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filterOptions.map((f) {
                    final selected = _selectedStatusFilter == f;
                    final label = f == 'all' ? 'All' : f[0].toUpperCase() + f.substring(1).replaceAll('_', ' ');
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
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
                        onSelected: (val) => setState(() => _selectedStatusFilter = f),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: portal.isLoading && portal.bookings.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
                  ),
                )
              : bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textLight),
                          const SizedBox(height: 12),
                          Text('No bookings found', style: GoogleFonts.inter(color: AppColors.textMedium)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.brandPink,
                      onRefresh: () => portal.loadBookings(token),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return _buildBookingCard(booking, token, portal);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(BookingModel booking, String token, VendorPortalProvider portal) {
    final next = _nextStatus(booking.status);
    final actionLabel = _nextStatusActionLabel(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.brandPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_month_outlined, color: AppColors.brandPink, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName ?? 'Customer',
                      style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    if (booking.serviceName != null) ...[
                      const SizedBox(height: 2),
                      Text(booking.serviceName!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
                    ],
                    if (booking.eventDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.event_outlined, size: 13, color: AppColors.primaryGold),
                          const SizedBox(width: 4),
                          Text(booking.eventDate!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.primaryGold, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(booking.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.statusLabel,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(booking.status),
                  ),
                ),
              ),
            ],
          ),

          // Actions for progression
          if (booking.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await portal.updateBookingStatus(token, booking.id, 'confirmed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: Text('Accept', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await portal.updateBookingStatus(token, booking.id, 'cancelled');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text('Decline', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else if (next.isNotEmpty && booking.status.toLowerCase() != 'cancelled') ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await portal.updateBookingStatus(token, booking.id, next);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(actionLabel, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
