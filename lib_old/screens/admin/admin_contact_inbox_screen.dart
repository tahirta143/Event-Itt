import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/admin_auth_provider.dart';
import '../../providers/admin/admin_contact_inbox_provider.dart';
import '../../utils/colors/app_colors.dart';

class AdminContactInboxScreen extends StatefulWidget {
  const AdminContactInboxScreen({super.key});

  @override
  State<AdminContactInboxScreen> createState() =>
      _AdminContactInboxScreenState();
}

class _AdminContactInboxScreenState extends State<AdminContactInboxScreen> {
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
    context.read<AdminContactInboxProvider>().loadInbox(token);
  }

  void _showInquiryDetail(BuildContext context, ContactInquiryModel item) {
    final token = context.read<AdminAuthProvider>().token ?? '';
    if (!item.isRead) {
      context.read<AdminContactInboxProvider>().markRead(token, item.id, true);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Message Detail',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
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
            Text(
              'From: ${item.name} (${item.email})',
              style: GoogleFonts.montserrat(
                  fontSize: 13, fontWeight: FontWeight.bold),
            ),
            if (item.phone != null && item.phone!.isNotEmpty)
              Text(
                'Phone: ${item.phone}',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textMedium),
              ),
            const SizedBox(height: 10),
            Text(
              'Subject: ${item.subject}',
              style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandPink),
            ),
            const Divider(height: 24),
            Text(
              item.message,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textDark, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: () async {
                      final err = await context
                          .read<AdminContactInboxProvider>()
                          .deleteInquiry(token, item.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (err != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(err)),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminContactInboxProvider>();
    final adminAuth = context.watch<AdminAuthProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Inbox',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    '${provider.unreadTotal} unread inquiry messages',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textMedium),
                  ),
                ],
              ),
              if (provider.unreadTotal > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandPink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider.unreadTotal} NEW',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Box
          TextField(
            controller: _searchController,
            onChanged: (val) => provider.loadInbox(
              adminAuth.token ?? '',
              search: val,
              page: 1,
            ),
            decoration: InputDecoration(
              hintText: 'Search by name, email, or subject...',
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
          else if (provider.inquiries.isEmpty)
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
                  const Icon(Icons.mark_email_read_rounded,
                      size: 48, color: AppColors.textLight),
                  const SizedBox(height: 12),
                  Text(
                    'Inbox is empty',
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
              itemCount: provider.inquiries.length,
              itemBuilder: (context, index) {
                final item = provider.inquiries[index];
                return GestureDetector(
                  onTap: () => _showInquiryDetail(context, item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: item.isRead
                          ? AppColors.cardWhite
                          : AppColors.brandPink.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: item.isRead
                            ? AppColors.lightGrey
                            : AppColors.brandPink.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: item.isRead
                              ? AppColors.lightGrey
                              : AppColors.brandPink,
                          radius: 18,
                          child: Icon(
                            item.isRead
                                ? Icons.mark_email_read_rounded
                                : Icons.mark_email_unread_rounded,
                            color: item.isRead
                                ? AppColors.textMedium
                                : Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: item.isRead
                                            ? FontWeight.w600
                                            : FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  if (item.createdAt != null)
                                    Text(
                                      item.createdAt!.split('T')[0],
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subject,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: item.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: AppColors.textMedium,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Pagination Controls
          if (provider.totalPages > 1) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: provider.currentPage > 1
                      ? () => provider.prevPage(adminAuth.token ?? '')
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Previous'),
                ),
                Text(
                  'Page ${provider.currentPage} of ${provider.totalPages}',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: provider.currentPage < provider.totalPages
                      ? () => provider.nextPage(adminAuth.token ?? '')
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  label: const Text('Next'),
                ),
              ],
            ),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
