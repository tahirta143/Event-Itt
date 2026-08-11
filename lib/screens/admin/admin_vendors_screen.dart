import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/admin_auth_provider.dart';
import '../../providers/admin/admin_vendors_provider.dart';
import '../../utils/colors/app_colors.dart';

class AdminVendorsScreen extends StatefulWidget {
  const AdminVendorsScreen({super.key});

  @override
  State<AdminVendorsScreen> createState() => _AdminVendorsScreenState();
}

class _AdminVendorsScreenState extends State<AdminVendorsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AdminAuthProvider>().token ?? '';
      context.read<AdminVendorsProvider>().loadVendors(token);
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF2E7D32);
      case 'inactive':
        return AppColors.textMedium;
      case 'pending':
        return const Color(0xFFE65100);
      default:
        return AppColors.textMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminVendorsProvider>();

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

    if (provider.vendors.isEmpty) {
      return Center(
        child: Text('No vendors found.',
            style: GoogleFonts.inter(color: AppColors.textMedium)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: provider.vendors.length + 1,
      itemBuilder: (context, index) {
        if (index == provider.vendors.length) {
          return const SizedBox(height: 100);
        }
        final vendor = provider.vendors[index];
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
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.brandPink.withOpacity(0.1),
                backgroundImage: vendor.logo != null && vendor.logo!.isNotEmpty
                    ? NetworkImage(vendor.logo!)
                    : null,
                child: vendor.logo == null || vendor.logo!.isEmpty
                    ? Text(
                        vendor.businessName.trim().isNotEmpty
                            ? vendor.businessName.trim()[0].toUpperCase()
                            : 'V',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandPink,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.businessName,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vendor.email,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textMedium),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _statusColor(vendor.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  vendor.status,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(vendor.status),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
