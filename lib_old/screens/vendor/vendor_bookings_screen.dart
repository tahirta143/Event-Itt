import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/vendor_auth_provider.dart';
import '../../providers/vendor/vendor_portal_provider.dart';
import '../../utils/colors/app_colors.dart';

class VendorBookingsScreen extends StatefulWidget {
  const VendorBookingsScreen({super.key});

  @override
  State<VendorBookingsScreen> createState() => _VendorBookingsScreenState();
}

class _VendorBookingsScreenState extends State<VendorBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<VendorAuthProvider>().token ?? '';
      if (context.read<VendorPortalProvider>().bookings.isEmpty) {
        context.read<VendorPortalProvider>().loadAll(token);
      }
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return AppColors.successGreen;
      case 'pending': return AppColors.discountOrange;
      case 'cancelled': return Colors.red;
      case 'completed': return AppColors.primaryGold;
      default: return AppColors.textMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<VendorPortalProvider>();
    final vendorAuth = context.watch<VendorAuthProvider>();

    if (portal.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
        ),
      );
    }

    if (portal.bookings.isEmpty) {
      return Center(
        child: Text('No bookings yet.',
            style: GoogleFonts.inter(color: AppColors.textMedium)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: portal.bookings.length + 1,
      itemBuilder: (context, index) {
        if (index == portal.bookings.length) return const SizedBox(height: 100);
        final booking = portal.bookings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.lightGrey),
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
                child: const Icon(Icons.calendar_month_rounded,
                    color: AppColors.brandPink, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName ?? 'Customer',
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark),
                    ),
                    if (booking.eventDate != null) ...[
                      const SizedBox(height: 2),
                      Text('📅 ${booking.eventDate}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textMedium)),
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
                          color: _statusColor(booking.status)),
                    ),
                  ),
                  if (booking.status == 'pending') ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _ActionButton(
                          label: '✓',
                          color: AppColors.successGreen,
                          onPressed: () async {
                            await portal.updateBookingStatus(
                                vendorAuth.token ?? '', booking.id, 'confirmed');
                          },
                        ),
                        const SizedBox(width: 4),
                        _ActionButton(
                          label: '✕',
                          color: Colors.red,
                          onPressed: () async {
                            await portal.updateBookingStatus(
                                vendorAuth.token ?? '', booking.id, 'cancelled');
                          },
                        ),
                      ],
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

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
