import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/booking/booking_model.dart';
import '../../providers/auth/customer_auth_provider.dart';
import '../../providers/customer/customer_bookings_provider.dart';
import '../../utils/colors/app_colors.dart';
import 'create_wedding_event_modal.dart';
import 'customer_booking_flow_sheet.dart';
import 'customer_invoice_modal.dart';
import 'customer_review_modal.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  static const Map<String, String> _eventCovers = {
    'engagement':
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&q=80',
    'mehndi':
        'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?w=600&q=80',
    'baraat':
        'https://images.unsplash.com/photo-1464366400600-7168b107af1c?w=600&q=80',
    'walima':
        'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=600&q=80',
    'nikkah':
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&q=80',
    'qawwali':
        'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&q=80',
    'reception':
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=600&q=80',
    'other':
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&q=80',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<CustomerAuthProvider>().token ?? '';
      context.read<CustomerBookingsProvider>().loadAll(token);
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.successGreen;
      case 'pending':
        return AppColors.discountOrange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return AppColors.primaryGold;
      default:
        return AppColors.textMedium;
    }
  }

  void _openBookingFlow(BuildContext context, {String? eventId}) {
    CustomerBookingFlowSheet.show(context, eventId: eventId);
  }

  void _openCreateEvent(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateWeddingEventModal(),
    );
  }

  void _openInvoiceModal(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerInvoiceModal(booking: booking),
    );
  }

  void _openReviewModal(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerReviewModal(booking: booking),
    );
  }

  void _showEventOptionsModal(BuildContext context, WeddingEventModel event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.brandPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.celebration_rounded,
                      color: AppColors.brandPink, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.customLabel,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        event.eventDate != null && event.eventDate!.isNotEmpty
                            ? 'Event Date: ${event.eventDate}'
                            : 'No date assigned',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: AppColors.lightGrey),
            const SizedBox(height: 12),

            // Option 1: Book Service for this event
            ListTile(
              leading: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.brandPink),
              title: Text(
                'Book a Service for ${event.customLabel}',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              subtitle: Text(
                'Attach a photographer, caterer, decor, or venue',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textMedium),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _openBookingFlow(context, eventId: event.id);
              },
            ),

            // Option 2: Toggle Filter
            Consumer<CustomerBookingsProvider>(
              builder: (context, provider, child) {
                final isFiltered = provider.selectedEventId == event.id;
                return ListTile(
                  leading: Icon(
                    isFiltered ? Icons.filter_alt_off_rounded : Icons.filter_alt_rounded,
                    color: AppColors.primaryGold,
                  ),
                  title: Text(
                    isFiltered ? 'Show All Bookings' : 'Filter Bookings for this Event',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  onTap: () {
                    provider.toggleEventFilter(event.id);
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancelBooking(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cancel Booking Request?',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel the booking for ${booking.serviceName ?? 'this service'}?',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Booking',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final token = context.read<CustomerAuthProvider>().token ?? '';
              final err = await context
                  .read<CustomerBookingsProvider>()
                  .cancelBooking(token, booking.id);
              if (err != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(err), backgroundColor: Colors.red),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking request has been cancelled.'),
                    backgroundColor: AppColors.textDark,
                  ),
                );
              }
            },
            child: Text(
              'Yes, Cancel',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveEventImage(WeddingEventModel event) {
    if (event.coverImageUrl != null && event.coverImageUrl!.isNotEmpty) {
      return event.coverImageUrl!;
    }
    final key = event.eventType.toLowerCase();
    return _eventCovers[key] ?? _eventCovers['engagement']!;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerBookingsProvider>();
    final customerAuth = context.watch<CustomerAuthProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
        ),
      );
    }

    final filteredList = provider.filteredBookings;
    final selectedEvent = provider.selectedWeddingEvent;

    return RefreshIndicator(
      onRefresh: () => provider.loadAll(customerAuth.token ?? ''),
      color: AppColors.brandPink,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Wedding Bookings',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Manage events & service bookings',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textMedium),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    elevation: 2,
                  ),
                  onPressed: () => _openBookingFlow(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    'Book Service',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Wedding Events Carousel Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'My Wedding Events',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${provider.weddingEvents.length})',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _openCreateEvent(context),
                  child: Row(
                    children: [
                      const Icon(Icons.add_rounded,
                          size: 16, color: AppColors.brandPink),
                      const SizedBox(width: 4),
                      Text(
                        'Add Event',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandPink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Interactive Event Cards Carousel with Images
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: provider.weddingEvents.length + 1,
                itemBuilder: (context, index) {
                  // Last Card: Add New Event
                  if (index == provider.weddingEvents.length) {
                    return InkWell(
                      onTap: () => _openCreateEvent(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.brandPink.withOpacity(0.35),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.brandPink.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: AppColors.brandPink, size: 22),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'New Event',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final ev = provider.weddingEvents[index];
                  final isSelected = provider.selectedEventId == ev.id;
                  final imgUrl = _resolveEventImage(ev);

                  return InkWell(
                    onTap: () => provider.toggleEventFilter(ev.id),
                    onLongPress: () => _showEventOptionsModal(context, ev),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGold
                              : Colors.transparent,
                          width: isSelected ? 2.5 : 0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? AppColors.primaryGold.withOpacity(0.3)
                                : Colors.black.withOpacity(0.12),
                            blurRadius: isSelected ? 12 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Event Cover Image
                            Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppColors.darkHeader,
                                child: const Icon(Icons.celebration_rounded,
                                    color: Colors.white, size: 32),
                              ),
                            ),

                            // Gradient Overlay for text contrast
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.2),
                                    Colors.black.withOpacity(0.75),
                                    Colors.black.withOpacity(0.9),
                                  ],
                                ),
                              ),
                            ),

                            // Top Badges (Selected status / Planned)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGold,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_rounded,
                                              size: 11,
                                              color: AppColors.textDark),
                                          const SizedBox(width: 2),
                                          Text(
                                            'FILTERED',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Bottom Content (Title, Date, Booking count)
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ev.customLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ev.eventDate != null &&
                                                  ev.eventDate!.isNotEmpty
                                              ? '📅 ${ev.eventDate!.length >= 10 ? ev.eventDate!.substring(0, 10) : ev.eventDate}'
                                              : 'Tap to filter',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGold
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${ev.bookingCount} Booked',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.champagne,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Active Event Filter Banner (if an event is selected)
            if (selectedEvent != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primaryGold.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list_rounded,
                              size: 18, color: AppColors.primaryGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Showing: ${selectedEvent.customLabel}',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _openBookingFlow(context,
                              eventId: selectedEvent.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.brandPink,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+ Book Service',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: AppColors.textDark),
                          onPressed: () => provider.toggleEventFilter(null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Bookings Section Header & Filter Tabs
            Text(
              'Booked Services',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),

            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip(provider, 'all', 'All'),
                  _buildFilterChip(provider, 'pending', 'Pending'),
                  _buildFilterChip(provider, 'confirmed', 'Confirmed'),
                  _buildFilterChip(provider, 'completed', 'Completed'),
                  _buildFilterChip(provider, 'cancelled', 'Cancelled'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bookings List
            if (filteredList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
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
                      'No ${provider.selectedFilter == 'all' ? '' : provider.selectedFilter} bookings found',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedEvent != null
                          ? 'No bookings found for "${selectedEvent.customLabel}". Tap "+ Book Service" to add one!'
                          : 'Tap "Book Service" above to schedule a new service request.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textMedium),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final booking = filteredList[index];
                  return _buildBookingCard(context, booking);
                },
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      CustomerBookingsProvider provider, String filterKey, String label) {
    final isSelected = provider.selectedFilter == filterKey;
    final count = provider.getCountByStatus(filterKey);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text('$label ($count)'),
        labelStyle: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textDark,
        ),
        selected: isSelected,
        selectedColor: AppColors.brandPink,
        backgroundColor: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppColors.brandPink : AppColors.borderGrey,
          ),
        ),
        onSelected: (_) => provider.setFilter(filterKey),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    final statusColor = _statusColor(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.event_note_rounded,
                    color: AppColors.brandPink, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName ?? 'Booking #${booking.id}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (booking.vendorName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '🏪 ${booking.vendorName}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textMedium),
                      ),
                    ],
                    if (booking.eventDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '📅 ${booking.eventDate}',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textLight),
                      ),
                    ],
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.statusLabel,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.lightGrey),
          const SizedBox(height: 10),

          // Financial & Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (booking.totalAmount != null && booking.totalAmount! > 0)
                      Text(
                        'Rs ${booking.totalAmount!.toStringAsFixed(0)}',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      )
                    else
                      Text(
                        'Price on quotation',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textMedium,
                        ),
                      ),
                    // Payment Status indicator
                    Text(
                      booking.paymentStatus == 'paid'
                          ? 'Paid in Full'
                          : (booking.paymentStatus == 'deposit_paid'
                              ? 'Deposit Paid'
                              : 'Payment Pending'),
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: booking.paymentStatus == 'paid'
                            ? AppColors.successGreen
                            : AppColors.discountOrange,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                children: [
                  // Invoice Button
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGold,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                    ),
                    onPressed: () => _openInvoiceModal(context, booking),
                    icon: const Icon(Icons.receipt_long_rounded, size: 16),
                    label: Text(
                      'Invoice',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Review Button (For completed bookings)
                  if (booking.status.toLowerCase() == 'completed') ...[
                    const SizedBox(width: 4),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.brandPink,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                      ),
                      onPressed: () => _openReviewModal(context, booking),
                      icon: const Icon(Icons.star_rounded, size: 16),
                      label: Text(
                        booking.reviewRating != null
                            ? '${booking.reviewRating}★'
                            : 'Review',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],

                  // Cancel Button (For pending bookings)
                  if (booking.status.toLowerCase() == 'pending') ...[
                    const SizedBox(width: 4),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                      ),
                      onPressed: () =>
                          _confirmCancelBooking(context, booking),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
