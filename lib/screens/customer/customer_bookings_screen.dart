import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/customer_auth_provider.dart';
import '../../providers/customer/customer_bookings_provider.dart';
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
      if (context.read<CustomerBookingsProvider>().bookings.isEmpty) {
        context.read<CustomerBookingsProvider>().loadMyBookings(token);
      }
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return const Color(0xFF2E7D32);
      case 'pending': return const Color(0xFFE65100);
      case 'cancelled': return Colors.red;
      case 'completed': return const Color(0xFF1565C0);
      default: return AppColors.textMedium;
    }
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

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(provider.error!,
                style: GoogleFonts.inter(color: AppColors.textMedium)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPink),
              onPressed: () => provider.loadMyBookings(customerAuth.token ?? ''),
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (provider.bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_outlined,
                size: 52, color: AppColors.textLight),
            const SizedBox(height: 14),
            Text(
              'No bookings yet.',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Browse services and make your first booking.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textMedium),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: provider.bookings.length + 1,
      itemBuilder: (context, index) {
        if (index == provider.bookings.length) {
          return const SizedBox(height: 100);
        }
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
                    if (booking.serviceName != null)
                      Text(
                        booking.serviceName!,
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
                    if (booking.totalAmount != null) ...[
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
    );
  }
}
