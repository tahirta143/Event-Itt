import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth/admin_auth_provider.dart';
import '../../providers/admin/admin_vendors_provider.dart';
import '../../providers/venue/venue_provider.dart';
import '../../models/auth/vendor_auth_model.dart';
import '../../models/subcategory/subcategory_model.dart';
import '../../utils/colors/app_colors.dart';

class AdminVendorsScreen extends StatefulWidget {
  const AdminVendorsScreen({super.key});

  @override
  State<AdminVendorsScreen> createState() => _AdminVendorsScreenState();
}

class _AdminVendorsScreenState extends State<AdminVendorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final token = context.read<AdminAuthProvider>().token ?? '';
    context.read<AdminVendorsProvider>().loadVendors(token);
    context.read<VenueProvider>().fetchPublicData();
  }

  String _resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return 'https://api.eventitt.afaqmis.com$url';
  }

  Widget _buildVendorAvatar(VendorAuthModel v) {
    final imgUrl = _resolveImageUrl(v.logo);
    if (imgUrl.isNotEmpty) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.network(
            imgUrl,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackAvatar(v),
          ),
        ),
      );
    }
    return _buildFallbackAvatar(v);
  }

  Widget _buildFallbackAvatar(VendorAuthModel v) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.brandPink.withOpacity(0.12),
      child: Text(
        v.vendorName.isNotEmpty ? v.vendorName[0].toUpperCase() : 'V',
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.brandPink,
        ),
      ),
    );
  }

  void _openVendorModal(BuildContext context, {VendorAuthModel? vendor}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditVendorModal(vendor: vendor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminVendorsProvider>();
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
                    'Vendors Directory',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Showing ${provider.vendors.length} of ${provider.totalCount} total vendors',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textMedium),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () => _openVendorModal(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Add Vendor',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Box
          TextField(
            controller: _searchController,
            onChanged: (val) => provider.loadVendors(
              adminAuth.token ?? '',
              search: val,
              page: 1,
            ),
            decoration: InputDecoration(
              hintText: 'Search vendor, business name, or city...',
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
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, provider, '', 'All Vendors'),
                _buildFilterChip(context, provider, 'active', 'Active Only'),
                _buildFilterChip(context, provider, 'inactive', 'Inactive'),
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
          else if (provider.vendors.isEmpty)
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
                  const Icon(Icons.storefront_outlined,
                      size: 48, color: AppColors.textLight),
                  const SizedBox(height: 12),
                  Text(
                    'No vendors found',
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
              itemCount: provider.vendors.length,
              itemBuilder: (context, index) {
                final v = provider.vendors[index];
                return GestureDetector(
                  onTap: () => _openVendorModal(context, vendor: v),
                  child: Container(
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
                        _buildVendorAvatar(v),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      v.businessName.isNotEmpty
                                          ? v.businessName
                                          : v.vendorName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: v.isActive
                                          ? AppColors.successGreen.withOpacity(0.12)
                                          : Colors.red.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      v.isActive ? 'Active' : 'Inactive',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: v.isActive
                                            ? AppColors.successGreen
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                v.vendorEmail,
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: AppColors.textMedium),
                              ),
                              if (v.businessAddress.isNotEmpty)
                                Text(
                                  '📍 ${v.businessAddress}',
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: AppColors.textLight),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textMedium, size: 20),
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

  Widget _buildFilterChip(
    BuildContext context,
    AdminVendorsProvider provider,
    String value,
    String label,
  ) {
    final isSelected = provider.statusFilter == value;
    return GestureDetector(
      onTap: () {
        final token = context.read<AdminAuthProvider>().token ?? '';
        provider.loadVendors(token, statusFilter: value, page: 1);
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

// ---------------------------------------------------------------------------
// Add / Edit Vendor Modal Dialog (All Fields + Image URL Upload + Subcategories Dropdown)
// ---------------------------------------------------------------------------

class _EditVendorModal extends StatefulWidget {
  final VendorAuthModel? vendor;

  const _EditVendorModal({this.vendor});

  @override
  State<_EditVendorModal> createState() => _EditVendorModalState();
}

class _EditVendorModalState extends State<_EditVendorModal> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _passwordController;
  late TextEditingController _logoUrlController;
  late bool _isActive;
  Set<String> _selectedSubcategoryIds = {};
  XFile? _pickedImage;
  bool _fetchingDetails = false;
  bool _saving = false;
  bool _deleting = false;
  String? _error;

  bool get isNew => widget.vendor == null;

  @override
  void initState() {
    super.initState();
    final v = widget.vendor;
    _nameController = TextEditingController(text: v != null ? (v.name.isNotEmpty ? v.name : v.businessName) : '');
    _emailController = TextEditingController(text: v?.email ?? '');
    _phoneController = TextEditingController(text: v?.phone ?? '');
    _addressController = TextEditingController(text: v?.businessAddress ?? '');
    _descriptionController = TextEditingController(text: v?.description ?? '');
    _passwordController = TextEditingController();
    _logoUrlController = TextEditingController(text: v?.logo ?? '');
    _isActive = v?.isActive ?? true;

    if (!isNew && v != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadVendorDetails(v.id));
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Image Source',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: AppColors.brandPink),
                  title: const Text('Photo Gallery'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: AppColors.brandPink),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
          ),
        ),
      );

      if (source == null) return;

      final picker = ImagePicker();
      final image = await picker.pickImage(source: source, imageQuality: 85);
      if (image != null) {
        setState(() => _pickedImage = image);
      }
    } catch (e, stack) {
      debugPrint('❌ [IMAGE PICKER ERROR] $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _loadVendorDetails(String vendorId) async {
    setState(() => _fetchingDetails = true);
    final token = context.read<AdminAuthProvider>().token ?? '';
    final details = await context.read<AdminVendorsProvider>().getVendorDetails(token, vendorId);

    if (mounted && details != null) {
      final subs = details['subcategories'] as List<dynamic>?;
      if (subs != null) {
        final ids = subs.map((s) => s['id']?.toString() ?? '').where((id) => id.isNotEmpty).toSet();
        setState(() {
          _selectedSubcategoryIds = ids;
        });
      }
    }
    if (mounted) setState(() => _fetchingDetails = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveVendor() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Vendor name is required.');
      return;
    }
    if (isNew && _passwordController.text.trim().isEmpty) {
      setState(() => _error = 'Password is required for new vendor.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final token = context.read<AdminAuthProvider>().token ?? '';
    final provider = context.read<AdminVendorsProvider>();

    String? err;
    if (isNew) {
      err = await provider.createVendor(
        token: token,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        password: _passwordController.text.trim(),
        logoUrl: _logoUrlController.text.trim(),
        imagePath: _pickedImage?.path,
        isActive: _isActive,
        subcategoryIds: _selectedSubcategoryIds.toList(),
      );
    } else {
      err = await provider.updateVendor(
        token: token,
        id: widget.vendor!.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        password: _passwordController.text.trim(),
        logoUrl: _logoUrlController.text.trim(),
        imagePath: _pickedImage?.path,
        isActive: _isActive,
        subcategoryIds: _selectedSubcategoryIds.toList(),
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (err == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNew ? 'Vendor created successfully!' : 'Vendor updated successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } else {
      setState(() => _error = err);
    }
  }

  Future<void> _confirmDeleteVendor() async {
    if (isNew || widget.vendor == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Vendor?',
          style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.vendor!.vendorName}"? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _deleting = true);
    final token = context.read<AdminAuthProvider>().token ?? '';
    final err = await context
        .read<AdminVendorsProvider>()
        .deleteVendor(token, widget.vendor!.id);

    if (!mounted) return;
    setState(() => _deleting = false);

    if (err == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vendor deleted.')),
      );
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final venueProvider = context.watch<VenueProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isNew ? 'Add New Vendor' : 'Edit Vendor Account',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
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

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_error!,
                  style: GoogleFonts.inter(color: Colors.red, fontSize: 12)),
            ),
            const SizedBox(height: 12),
          ],

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor Logo / Image Upload Section
                  Text('Vendor Logo / Image',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPink.withOpacity(0.12),
                          foregroundColor: AppColors.brandPink,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                        label: Text(
                          _pickedImage == null ? 'Upload Image from Mobile' : 'Change Selected Image',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_pickedImage != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                          onPressed: () => setState(() => _pickedImage = null),
                          tooltip: 'Remove picked image',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_pickedImage != null)
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.brandPink, width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_pickedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else if (_logoUrlController.text.trim().isNotEmpty)
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _logoUrlController.text.trim().startsWith('http')
                              ? _logoUrlController.text.trim()
                              : 'https://api.eventitt.afaqmis.com${_logoUrlController.text.trim()}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image_outlined,
                                color: Colors.red),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),

                  // Vendor Name
                  Text('Vendor / Business Name',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Email
                  Text('Contact Email',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Phone
                  Text('Contact Phone',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Address / City
                  Text('Business Address / City',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Description
                  Text('Description',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Password
                  Text(isNew ? 'Password *' : 'New Password (optional)',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: isNew ? 'Set login password' : 'Leave blank to keep unchanged',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Linked Subcategories Selector
                  Text('Linked Sub-Categories (Menu Services)',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),

                  if (_fetchingDetails)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: null,
                      menuMaxHeight: 220,
                      hint: Text(
                        _selectedSubcategoryIds.isEmpty
                            ? 'Select subcategory to add...'
                            : '${_selectedSubcategoryIds.length} Linked Subcategories',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      items: venueProvider.subCategories.map((sub) {
                        final isSelected = _selectedSubcategoryIds.contains(sub.id);
                        return DropdownMenuItem(
                          value: sub.id,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                color: isSelected
                                    ? AppColors.brandPink
                                    : AppColors.textMedium,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  sub.title,
                                  style: GoogleFonts.inter(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            if (_selectedSubcategoryIds.contains(val)) {
                              _selectedSubcategoryIds.remove(val);
                            } else {
                              _selectedSubcategoryIds.add(val);
                            }
                          });
                        }
                      },
                    ),

                  if (_selectedSubcategoryIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: venueProvider.subCategories
                          .where((sub) => _selectedSubcategoryIds.contains(sub.id))
                          .map((sub) => Chip(
                                label: Text(sub.title,
                                    style: const TextStyle(fontSize: 11)),
                                backgroundColor:
                                    AppColors.brandPink.withOpacity(0.1),
                                deleteIcon: const Icon(Icons.close_rounded,
                                    size: 14, color: AppColors.brandPink),
                                onDeleted: () {
                                  setState(() {
                                    _selectedSubcategoryIds.remove(sub.id);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Active / Deactive Switch
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Account Status',
                        style: GoogleFonts.montserrat(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _isActive ? 'Active — vendor listed' : 'Inactive — vendor hidden',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textMedium),
                      ),
                      activeColor: AppColors.brandPink,
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Action Buttons: Delete & Save
          Row(
            children: [
              if (!isNew) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed:
                      (_saving || _deleting) ? null : _confirmDeleteVendor,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Delete'),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: (_saving || _deleting) ? null : _saveVendor,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isNew ? 'Create Vendor' : 'Save Changes',
                          style: GoogleFonts.montserrat(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
