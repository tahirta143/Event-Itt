import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/customer_auth_provider.dart';
import '../../providers/customer/customer_bookings_provider.dart';
import '../../providers/venue/venue_provider.dart';
import '../../utils/colors/app_colors.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  State<CustomerBookingsScreen> createState() =>
      _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
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
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFE65100);
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return const Color(0xFF1565C0);
      default:
        return AppColors.textMedium;
    }
  }

  void _openBookingForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _BookingFormModal(),
    );
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
                  ),
                  onPressed: () => _openBookingForm(context),
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

            // Wedding Events Carousel
            if (provider.weddingEvents.isNotEmpty) ...[
              Text(
                'My Wedding Events',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: provider.weddingEvents.length,
                  itemBuilder: (context, index) {
                    final ev = provider.weddingEvents[index];
                    return Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.darkHeader,
                            AppColors.brandPink.withOpacity(0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                              Text(
                                ev.customLabel,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Icon(Icons.auto_awesome_rounded,
                                  size: 14, color: AppColors.champagne),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (ev.eventDate != null && ev.eventDate!.isNotEmpty)
                                Text(
                                  '📅 ${ev.eventDate}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              Text(
                                '${ev.bookingCount} Booking${ev.bookingCount == 1 ? '' : 's'}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.champagne,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Bookings Section Header
            Text(
              'Booked Services',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),

            if (provider.bookings.isEmpty)
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
                      'No bookings yet',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap "Book Service" above to submit a new booking request.',
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
                itemCount: provider.bookings.length,
                itemBuilder: (context, index) {
                  final booking = provider.bookings[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.brandPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.event_rounded,
                              color: AppColors.brandPink, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.serviceName ?? 'Booking #${booking.id}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
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
                              if (booking.totalAmount != null && booking.totalAmount! > 0) ...[
                                const SizedBox(height: 4),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(booking.status).withOpacity(0.1),
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
                            if (booking.status == 'pending') ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final err = await provider.cancelBooking(
                                    customerAuth.token ?? '',
                                    booking.id,
                                  );
                                  if (err != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(err)),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.red.withOpacity(0.25)),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Booking Form Bottom Sheet Modal
// ---------------------------------------------------------------------------

class _BookingFormModal extends StatefulWidget {
  const _BookingFormModal();

  @override
  State<_BookingFormModal> createState() => _BookingFormModalState();
}

class _BookingFormModalState extends State<_BookingFormModal> {
  String? _selectedSubcategoryId;
  String? _selectedEventId;
  DateTime? _selectedDate;
  final TextEditingController _guestController =
      TextEditingController(text: '150');
  final TextEditingController _notesController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _guestController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (_selectedSubcategoryId == null) {
      setState(() => _error = 'Please select a service subcategory.');
      return;
    }
    if (_selectedDate == null) {
      setState(() => _error = 'Please pick an event date.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final token = context.read<CustomerAuthProvider>().token ?? '';
    final dateStr =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    final guests = int.tryParse(_guestController.text) ?? 100;

    final err = await context.read<CustomerBookingsProvider>().createBooking(
          token: token,
          subcategoryId: _selectedSubcategoryId!,
          eventId: _selectedEventId,
          eventDate: dateStr,
          guestCount: guests,
          specialRequests: _notesController.text,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (err == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking request submitted successfully!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final venueProvider = context.watch<VenueProvider>();
    final customerBookings = context.watch<CustomerBookingsProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Book a Service',
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

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_error!,
                  style: GoogleFonts.inter(color: Colors.red, fontSize: 12)),
            ),
            const SizedBox(height: 12),
          ],

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Subcategory Dropdown
                  Text('Select Sub-Category Service',
                      style: GoogleFonts.montserrat(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedSubcategoryId,
                    hint: const Text('Choose a service...'),
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    items: venueProvider.subCategories.map((sub) {
                      return DropdownMenuItem(
                        value: sub.id,
                        child: Text(sub.title),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedSubcategoryId = val),
                  ),

                  const SizedBox(height: 16),

                  // Wedding Event Selection
                  Text('Attach to Event',
                      style: GoogleFonts.montserrat(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedEventId,
                    hint: const Text('Choose event (e.g. Baraat, Walima)'),
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    items: customerBookings.weddingEvents.map((ev) {
                      return DropdownMenuItem(
                        value: ev.id,
                        child: Text('${ev.customLabel} (${ev.eventType})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedEventId = val;
                        if (val != null) {
                          final ev = customerBookings.weddingEvents.firstWhere(
                            (e) => e.id == val,
                            orElse: () => const WeddingEventModel(id: '', eventType: '', customLabel: ''),
                          );
                          if (ev.eventDate != null && ev.eventDate!.isNotEmpty) {
                            final parsed = DateTime.tryParse(ev.eventDate!);
                            if (parsed != null) {
                              _selectedDate = parsed;
                            }
                          }
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Event Date Picker
                  Text('Event Date',
                      style: GoogleFonts.montserrat(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Select event date',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: _selectedDate != null
                                  ? AppColors.textDark
                                  : AppColors.textMedium,
                            ),
                          ),
                          const Icon(Icons.calendar_today_rounded,
                              size: 18, color: AppColors.brandPink),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Guest Count
                  Text('Guest Count',
                      style: GoogleFonts.montserrat(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _guestController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Special Requests
                  Text('Special Requests / Notes',
                      style: GoogleFonts.montserrat(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Theme preferences, dietary requirements...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _submitting ? null : _submitBooking,
              child: _submitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Submit Booking Request',
                      style: GoogleFonts.montserrat(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
