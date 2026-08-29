import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/vendor_auth_provider.dart';
import '../../providers/vendor/vendor_requests_provider.dart';
import '../../models/vendor/vendor_models.dart';
import '../../utils/colors/app_colors.dart';

class VendorRequestsScreen extends StatefulWidget {
  const VendorRequestsScreen({super.key});

  @override
  State<VendorRequestsScreen> createState() => _VendorRequestsScreenState();
}

class _VendorRequestsScreenState extends State<VendorRequestsScreen> {
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<VendorAuthProvider>().token ?? '';
      context.read<VendorRequestsProvider>().fetchRequests(token);
    });
  }

  void _openNewRequestSheet(String token) {
    final reqProv = context.read<VendorRequestsProvider>();
    reqProv.fetchCatalogCategories(token);

    dynamic selectedCat;
    dynamic selectedSub;
    final reasonController = TextEditingController();

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
              final prov = context.watch<VendorRequestsProvider>();
              final categories = prov.catalogCategories;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Request New Offering',
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
                  const SizedBox(height: 16),

                  // Category Dropdown
                  Text('Category', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        isExpanded: true,
                        hint: Text('Select Category', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textLight)),
                        value: selectedCat,
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat.name, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            selectedCat = val;
                            selectedSub = null;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Subcategory Dropdown
                  if (selectedCat != null) ...[
                    Text('Subcategory Offering', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<dynamic>(
                          isExpanded: true,
                          hint: Text('Select Subcategory', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textLight)),
                          value: selectedSub,
                          items: (selectedCat.subcategories as List<dynamic>).map((sub) {
                            return DropdownMenuItem(
                              value: sub,
                              child: Text(sub.name, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setModalState(() {
                              selectedSub = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Notes / Reason
                  Text('Reason / Notes (Optional)', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. We have specialized team and equipment for this…',
                      hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight),
                      filled: true,
                      fillColor: AppColors.lightBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGrey)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGrey)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.brandPink)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: selectedSub == null || prov.isSaving
                          ? null
                          : () async {
                              final ok = await prov.submitRequest(
                                token,
                                requestType: 'link',
                                subcategoryId: selectedSub.id is int ? selectedSub.id : int.tryParse(selectedSub.id.toString()) ?? 0,
                                reason: reasonController.text.trim(),
                              );
                              if (ok && mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Offering request submitted successfully!')),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: prov.isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Submit Request', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final reqProv = context.watch<VendorRequestsProvider>();
    final vendorAuth = context.watch<VendorAuthProvider>();
    final token = vendorAuth.token ?? '';

    final filteredList = reqProv.requests.where((r) {
      if (_statusFilter == 'all') return true;
      return r.status.toLowerCase() == _statusFilter;
    }).toList();

    return reqProv.isLoading && reqProv.requests.isEmpty
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
            ),
          )
        : RefreshIndicator(
            color: AppColors.brandPink,
            onRefresh: () => reqProv.fetchRequests(token),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.near_me_outlined, color: AppColors.brandPink, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Service Requests',
                                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Request to link or unlink catalog services',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _openNewRequestSheet(token),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text('New', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['all', 'pending', 'approved', 'rejected'].map((st) {
                        final selected = _statusFilter == st;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(st[0].toUpperCase() + st.substring(1)),
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
                            onSelected: (val) => setState(() => _statusFilter = st),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Requests List
                  if (filteredList.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 40, color: AppColors.textMedium.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'No service requests found.',
                            style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap "New" to request adding a new service offering.',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      itemBuilder: (context, idx) {
                        final req = filteredList[idx];
                        Color badgeColor = AppColors.primaryGold;
                        if (req.status.toLowerCase() == 'approved') {
                          badgeColor = AppColors.successGreen;
                        } else if (req.status.toLowerCase() == 'rejected') {
                          badgeColor = Colors.red;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.lightGrey),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      req.subcategoryName ?? 'Service Offering',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      req.status.toUpperCase(),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: badgeColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (req.categoryName != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  req.categoryName!,
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.brandPink, fontWeight: FontWeight.w600),
                                ),
                              ],
                              if (req.reason != null && req.reason!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightBackground,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    req.reason!,
                                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textDark),
                                  ),
                                ),
                              ],
                              if (req.adminNote != null && req.adminNote!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Admin Response: ${req.adminNote!}',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: badgeColor),
                                ),
                              ],
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
