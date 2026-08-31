import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/booking/booking_model.dart';
import '../../providers/auth/customer_auth_provider.dart';
import '../../providers/customer/customer_bookings_provider.dart';
import '../../utils/colors/app_colors.dart';

class CustomerInvoiceModal extends StatefulWidget {
  final BookingModel booking;

  const CustomerInvoiceModal({super.key, required this.booking});

  @override
  State<CustomerInvoiceModal> createState() => _CustomerInvoiceModalState();
}

class _CustomerInvoiceModalState extends State<CustomerInvoiceModal> {
  final TextEditingController _partialController = TextEditingController();
  bool _showPartialInput = false;
  bool _processingCod = false;
  bool _processingPartial = false;
  bool _processingOnline = false;
  String? _error;
  String? _successMessage;

  @override
  void dispose() {
    _partialController.dispose();
    super.dispose();
  }

  Future<void> _handleCOD() async {
    setState(() {
      _processingCod = true;
      _error = null;
      _successMessage = null;
    });

    final token = context.read<CustomerAuthProvider>().token ?? '';
    final err = await context.read<CustomerBookingsProvider>().confirmCOD(
          token,
          widget.booking.id,
        );

    if (!mounted) return;
    setState(() => _processingCod = false);

    if (err == null) {
      setState(() {
        _successMessage = 'Cash on Delivery confirmed for this booking!';
      });
    } else {
      setState(() => _error = err);
    }
  }

  Future<void> _handlePartialPayment() async {
    final amount = double.tryParse(_partialController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Please enter a valid payment amount.');
      return;
    }

    setState(() {
      _processingPartial = true;
      _error = null;
      _successMessage = null;
    });

    final token = context.read<CustomerAuthProvider>().token ?? '';
    final err = await context
        .read<CustomerBookingsProvider>()
        .confirmPartialPayment(token, widget.booking.id, amount);

    if (!mounted) return;
    setState(() => _processingPartial = false);

    if (err == null) {
      setState(() {
        _showPartialInput = false;
        _partialController.clear();
        _successMessage =
            'Advance payment of Rs ${amount.toStringAsFixed(0)} confirmed!';
      });
    } else {
      setState(() => _error = err);
    }
  }

  Future<void> _handleOnlinePayment(bool isSafepay) async {
    setState(() {
      _processingOnline = true;
      _error = null;
      _successMessage = null;
    });

    final token = context.read<CustomerAuthProvider>().token ?? '';
    final sessionData = isSafepay
        ? await context
            .read<CustomerBookingsProvider>()
            .createSafepaySession(token, widget.booking.id)
        : await context
            .read<CustomerBookingsProvider>()
            .createStripePaymentSession(token, widget.booking.id);

    if (!mounted) return;
    setState(() => _processingOnline = false);

    final url = sessionData?['url']?.toString();
    if (url != null && url.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment Session initialized. Checkout URL: $url',
          ),
          backgroundColor: AppColors.primaryGold,
        ),
      );
    } else {
      setState(() => _error = 'Could not initiate online payment gateway session.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final total = booking.estimatedValue ?? booking.totalAmount ?? 0;
    final deposit = booking.depositAmount ?? 0;
    final paid = booking.totalPaid ??
        (booking.paymentStatus == 'paid'
            ? total
            : (booking.paymentStatus == 'deposit_paid' ? deposit : 0));
    final balance = booking.remainingBalance;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Modal Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Invoice',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      booking.invoiceNumber != null
                          ? 'Invoice #${booking.invoiceNumber}'
                          : 'Booking #${booking.id}',
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
          ),

          const Divider(height: 24, thickness: 1, color: AppColors.lightGrey),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _error!,
                        style: GoogleFonts.inter(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  if (_successMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.successGreen, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: GoogleFonts.inter(
                                color: AppColors.successGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Service & Event Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              booking.serviceName ?? 'Service Booking',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _paymentStatusColor(booking.paymentStatus)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _paymentStatusLabel(booking.paymentStatus),
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _paymentStatusColor(booking.paymentStatus),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (booking.vendorName != null)
                          _buildDetailRow('Vendor / Venue', booking.vendorName!),
                        if (booking.eventDate != null)
                          _buildDetailRow('Event Date', booking.eventDate!),
                        if (booking.guestCount != null && booking.guestCount! > 0)
                          _buildDetailRow(
                              'Guest Count', '${booking.guestCount} Guests'),
                        if (booking.paymentMethod != null)
                          _buildDetailRow(
                              'Payment Method', booking.paymentMethod!.toUpperCase()),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Financial Breakdown Summary
                  Text(
                    'Payment Summary',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderGrey),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildPriceRow('Total Estimated Value', total),
                        const SizedBox(height: 8),
                        if (deposit > 0) ...[
                          _buildPriceRow('Required Advance Deposit', deposit,
                              isHighlighted: true),
                          const SizedBox(height: 8),
                        ],
                        _buildPriceRow('Total Paid So Far', paid,
                            color: AppColors.successGreen),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: AppColors.borderGrey),
                        ),
                        _buildPriceRow('Remaining Balance Due', balance,
                            isBold: true, color: AppColors.brandPink),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Options Section
                  if (booking.paymentStatus != 'paid' && balance > 0) ...[
                    Text(
                      'Select Payment Option',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Option 1: Cash on Delivery
                    _buildPaymentOptionTile(
                      icon: Icons.payments_outlined,
                      title: 'Cash on Delivery (Pay at Event)',
                      subtitle: 'Declare intent to settle dues directly on event day.',
                      isLoading: _processingCod,
                      onTap: _handleCOD,
                    ),

                    const SizedBox(height: 10),

                    // Option 2: Pay Custom Advance Deposit
                    _buildPaymentOptionTile(
                      icon: Icons.price_change_outlined,
                      title: 'Pay Custom Advance Amount',
                      subtitle: 'Make a partial deposit payment towards your booking.',
                      onTap: () {
                        setState(() {
                          _showPartialInput = !_showPartialInput;
                        });
                      },
                    ),

                    if (_showPartialInput) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderGrey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Advance Amount (PKR)',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _partialController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'e.g. 25000',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brandPink,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _processingPartial
                                      ? null
                                      : _handlePartialPayment,
                                  child: _processingPartial
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Confirm'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Option 3: Safepay / Digital Wallets
                    _buildPaymentOptionTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Safepay (JazzCash / EasyPaisa / Cards)',
                      subtitle: 'Pay securely via instant local payment methods.',
                      isLoading: _processingOnline,
                      onTap: () => _handleOnlinePayment(true),
                    ),

                    const SizedBox(height: 10),

                    // Option 4: Stripe Checkout (Credit / Debit Card)
                    _buildPaymentOptionTile(
                      icon: Icons.credit_card_outlined,
                      title: 'Stripe International Checkout',
                      subtitle: 'Fast and secure global card payments.',
                      isLoading: _processingOnline,
                      onTap: () => _handleOnlinePayment(false),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textMedium)),
          Text(value,
              style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isBold = false,
    bool isHighlighted = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? AppColors.primaryGold : AppColors.textDark,
          ),
        ),
        Text(
          'Rs ${amount.toStringAsFixed(0)}',
          style: GoogleFonts.montserrat(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.brandPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.brandPink, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandPink,
                ),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }

  Color _paymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return AppColors.successGreen;
      case 'deposit_paid':
        return AppColors.primaryGold;
      default:
        return AppColors.discountOrange;
    }
  }

  String _paymentStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return 'Paid in Full';
      case 'deposit_paid':
        return 'Deposit Paid';
      default:
        return 'Payment Pending';
    }
  }
}
