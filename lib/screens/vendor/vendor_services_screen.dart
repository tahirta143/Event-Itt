import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/vendor_auth_provider.dart';
import '../../providers/vendor/vendor_services_provider.dart';
import '../../models/vendor/vendor_models.dart';
import '../../utils/colors/app_colors.dart';

class VendorServicesScreen extends StatefulWidget {
  const VendorServicesScreen({super.key});

  @override
  State<VendorServicesScreen> createState() => _VendorServicesScreenState();
}

class _VendorServicesScreenState extends State<VendorServicesScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<VendorAuthProvider>().token ?? '';
      context.read<VendorServicesProvider>().fetchMyServices(token);
    });
  }

  void _openEditPricingSheet(VendorSubcategoryModel item, String token) {
    final priceController = TextEditingController(text: item.price != null ? item.price!.toStringAsFixed(0) : '');
    final minGuestsController = TextEditingController(text: item.minGuests?.toString() ?? '');
    final maxGuestsController = TextEditingController(text: item.maxGuests?.toString() ?? '');
    final notesController = TextEditingController(text: item.capacityNotes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final servicesProv = context.watch<VendorServicesProvider>();
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Pricing & Capacity',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textMedium),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  Text(
                    item.name,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 16),

                  // Price Input
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Starting Price (PKR)',
                      labelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                      prefixText: 'Rs ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Min & Max Guests
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minGuestsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Min Guests',
                            labelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxGuestsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Max Guests',
                            labelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Capacity Notes
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Capacity Notes / Package Details',
                      labelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: servicesProv.isSaving
                          ? null
                          : () async {
                              final double? price = double.tryParse(priceController.text.trim());
                              final int? minG = int.tryParse(minGuestsController.text.trim());
                              final int? maxG = int.tryParse(maxGuestsController.text.trim());
                              final String notes = notesController.text.trim();

                              final ok = await servicesProv.updatePricingAndCapacity(
                                token,
                                subcategoryId: item.id,
                                price: price,
                                minGuests: minG,
                                maxGuests: maxG,
                                capacityNotes: notes,
                              );

                              if (ok && mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Service pricing updated successfully!')),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: servicesProv.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Save Changes', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Color _approvalColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return AppColors.successGreen;
      case 'pending': return AppColors.discountOrange;
      case 'rejected': return Colors.red;
      default: return AppColors.textMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesProv = context.watch<VendorServicesProvider>();
    final vendorAuth = context.watch<VendorAuthProvider>();
    final token = vendorAuth.token ?? '';

    List<VendorSubcategoryModel> items = servicesProv.allSubcategories;

    if (_statusFilter != 'all') {
      items = items.where((i) => i.approvalStatus.toLowerCase() == _statusFilter).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      items = items.where((i) {
        return i.name.toLowerCase().contains(q) ||
            (i.serviceName?.toLowerCase().contains(q) ?? false) ||
            (i.categoryName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return Column(
      children: [
        // Search & Status filters
        Container(
          color: AppColors.lightBackground,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            children: [
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
                    hintText: 'Search my services...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textLight),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.brandPink, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ['all', 'approved', 'pending', 'rejected'].map((f) {
                    final selected = _statusFilter == f;
                    final label = f == 'all' ? 'All Services' : f == 'approved' ? 'Live' : f[0].toUpperCase() + f.substring(1);
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
                        onSelected: (val) => setState(() => _statusFilter = f),
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
          child: servicesProv.isLoading && servicesProv.allSubcategories.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
                  ),
                )
              : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.room_service_outlined, size: 48, color: AppColors.textLight),
                          const SizedBox(height: 12),
                          Text('No services found.', style: GoogleFonts.inter(color: AppColors.textMedium)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.brandPink,
                      onRefresh: () => servicesProv.fetchMyServices(token),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildServiceCard(item, token);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(VendorSubcategoryModel item, String token) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (item.categoryName != null || item.serviceName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${item.serviceName ?? ''} · ${item.categoryName ?? ''}',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      item.price != null ? 'Rs ${item.price!.toStringAsFixed(0)}' : 'Pricing not set',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: item.price != null ? AppColors.textDark : AppColors.discountOrange,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _approvalColor(item.approvalStatus).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.approvalStatus == 'approved' ? 'Live' : item.approvalStatus,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _approvalColor(item.approvalStatus),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.lightGrey),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.minGuests != null || item.maxGuests != null
                    ? 'Capacity: ${item.minGuests ?? 0} - ${item.maxGuests ?? '∞'} guests'
                    : 'Capacity: Not configured',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium),
              ),
              InkWell(
                onTap: () => _openEditPricingSheet(item, token),
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 14, color: AppColors.brandPink),
                    const SizedBox(width: 4),
                    Text(
                      'Edit Pricing',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandPink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.room_service_rounded,
          color: AppColors.textLight,
          size: 28,
        ),
      );
}
