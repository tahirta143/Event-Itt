import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/admin_auth_provider.dart';
import '../../providers/admin/admin_vendor_requests_provider.dart';
import '../../utils/colors/app_colors.dart';

class AdminVendorRequestsScreen extends StatefulWidget {
  const AdminVendorRequestsScreen({super.key});

  @override
  State<AdminVendorRequestsScreen> createState() =>
      _AdminVendorRequestsScreenState();
}

class _AdminVendorRequestsScreenState extends State<AdminVendorRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final token = context.read<AdminAuthProvider>().token ?? '';
    context.read<AdminVendorRequestsProvider>().loadRequests(token);
  }

  void _showRejectDialog(BuildContext context, String requestId) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reject Proposal',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reason for rejecting this vendor proposal:',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final token = context.read<AdminAuthProvider>().token ?? '';
              final err = await context
                  .read<AdminVendorRequestsProvider>()
                  .rejectRequest(token, requestId, noteController.text);
              if (context.mounted) {
                Navigator.pop(context);
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err)),
                  );
                }
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminVendorRequestsProvider>();
    final adminAuth = context.watch<AdminAuthProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vendor Proposals & Requests',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            'Review sub-category menu requests submitted by vendors',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
          ),
          const SizedBox(height: 16),

          // Search & Filter Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.loadRequests(
                    adminAuth.token ?? '',
                    search: val,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search requests or vendor...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    filled: true,
                    fillColor: AppColors.cardWhite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Filters Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, provider, 'pending', 'Pending'),
                _buildFilterChip(context, provider, 'approved', 'Approved'),
                _buildFilterChip(context, provider, 'rejected', 'Rejected'),
                _buildFilterChip(context, provider, '', 'All Requests'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
                ),
              ),
            )
          else if (provider.requests.isEmpty)
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
                  const Icon(Icons.inbox_rounded,
                      size: 48, color: AppColors.textLight),
                  const SizedBox(height: 12),
                  Text(
                    'No requests found',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.requests.length,
              itemBuilder: (context, index) {
                final req = provider.requests[index];
                final isPending = req.status == 'pending';

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: req.type == 'link'
                                  ? AppColors.brandPink.withOpacity(0.12)
                                  : Colors.red.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              req.type == 'link' ? '+ Add Category' : '- Remove',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: req.type == 'link'
                                    ? AppColors.brandPink
                                    : Colors.red,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: req.status == 'approved'
                                  ? AppColors.successGreen.withOpacity(0.12)
                                  : req.status == 'rejected'
                                      ? Colors.red.withOpacity(0.12)
                                      : Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              req.status.toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: req.status == 'approved'
                                    ? AppColors.successGreen
                                    : req.status == 'rejected'
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${req.subcategoryName} (${req.categoryName})',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vendor: ${req.vendorName} (${req.vendorEmail})',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textMedium),
                      ),
                      if (req.rejectionNote != null &&
                          req.rejectionNote!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Note: ${req.rejectionNote}',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.red,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                      if (isPending) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.successGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final err = await provider.approveRequest(
                                    adminAuth.token ?? '',
                                    req.id,
                                  );
                                  if (err != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(err)),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.check_rounded, size: 16),
                                label: const Text('Approve'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () =>
                                    _showRejectDialog(context, req.id),
                                icon: const Icon(Icons.close_rounded, size: 16),
                                label: const Text('Reject'),
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    AdminVendorRequestsProvider provider,
    String value,
    String label,
  ) {
    final isSelected = provider.statusFilter == value;
    return GestureDetector(
      onTap: () {
        final token = context.read<AdminAuthProvider>().token ?? '';
        provider.loadRequests(token, status: value);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPink : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandPink : AppColors.lightGrey,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
