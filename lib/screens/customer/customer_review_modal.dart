import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/booking/booking_model.dart';
import '../../providers/auth/customer_auth_provider.dart';
import '../../providers/customer/customer_bookings_provider.dart';
import '../../utils/colors/app_colors.dart';

class CustomerReviewModal extends StatefulWidget {
  final BookingModel booking;

  const CustomerReviewModal({super.key, required this.booking});

  @override
  State<CustomerReviewModal> createState() => _CustomerReviewModalState();
}

class _CustomerReviewModalState extends State<CustomerReviewModal> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;
  String? _error;

  static const List<String> _ratingLabels = [
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Exceptional Experience!',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    final token = context.read<CustomerAuthProvider>().token ?? '';
    final err = await context.read<CustomerBookingsProvider>().submitReview(
          token: token,
          bookingId: widget.booking.id,
          rating: _rating,
          comment: _commentController.text,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (err == null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Your review has been published.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: bottomInset + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate & Review',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      widget.booking.serviceName ?? 'Booking #${widget.booking.id}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMedium),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Star Rating Selector
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        iconSize: 36,
                        icon: Icon(
                          starIndex <= _rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.starRating,
                        ),
                        onPressed: () => setState(() => _rating = starIndex),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _ratingLabels[(_rating - 1).clamp(0, 4)],
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Review text
            Text(
              'Your Feedback (Optional)',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience with the venue or vendor...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
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
                  elevation: 2,
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit Review',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
