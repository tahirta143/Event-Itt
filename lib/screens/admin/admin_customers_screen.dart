import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/admin_auth_provider.dart';
import '../../providers/admin/admin_customers_provider.dart';
import '../../utils/colors/app_colors.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AdminAuthProvider>().token ?? '';
      context.read<AdminCustomersProvider>().loadCustomers(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCustomersProvider>();

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Text(provider.error!,
            style: GoogleFonts.inter(color: AppColors.textMedium)),
      );
    }

    if (provider.customers.isEmpty) {
      return Center(
        child: Text('No customers found.',
            style: GoogleFonts.inter(color: AppColors.textMedium)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: provider.customers.length + 1,
      itemBuilder: (context, index) {
        if (index == provider.customers.length) {
          return const SizedBox(height: 100);
        }
        final customer = provider.customers[index];
        return Container(
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
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
                child: Text(
                  customer.name.trim().isNotEmpty
                      ? customer.name.trim()[0].toUpperCase()
                      : 'C',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.email,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textMedium),
                    ),
                    if (customer.phone != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        customer.phone!,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textLight),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textLight, size: 20),
            ],
          ),
        );
      },
    );
  }
}
