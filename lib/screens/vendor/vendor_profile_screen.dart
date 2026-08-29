import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/vendor_auth_provider.dart';
import '../../providers/vendor/vendor_profile_provider.dart';
import '../../providers/vendor/vendor_portal_provider.dart';
import '../../utils/colors/app_colors.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _currentPwController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<VendorAuthProvider>().token ?? '';
      final profileProv = context.read<VendorProfileProvider>();
      profileProv.fetchProfile(token).then((_) {
        final profile = profileProv.profile;
        if (profile != null && mounted) {
          setState(() {
            _nameController.text = profile.name;
            _phoneController.text = profile.contactPhone ?? '';
            _cityController.text = profile.city ?? '';
            _addressController.text = profile.address ?? '';
            _descriptionController.text = profile.description ?? '';
            _initialized = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<VendorProfileProvider>();
    final vendorAuth = context.watch<VendorAuthProvider>();
    final token = vendorAuth.token ?? '';
    final profile = profileProv.profile;

    final checklist = [
      {'label': 'Business name', 'done': _nameController.text.trim().length >= 2},
      {'label': 'Contact information', 'done': _phoneController.text.trim().isNotEmpty},
      {'label': 'Description', 'done': _descriptionController.text.trim().isNotEmpty},
      {'label': 'Portfolio photos', 'done': profileProv.portfolioCount > 0},
      {'label': 'Availability marked', 'done': profileProv.blackoutCount > 0},
      {'label': 'Business address & city', 'done': _addressController.text.trim().isNotEmpty && _cityController.text.trim().isNotEmpty},
    ];

    final doneCount = checklist.where((i) => i['done'] == true).length;
    final percent = ((doneCount / checklist.length) * 100).round();

    return profileProv.isLoading && !_initialized
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPink),
            ),
          )
        : RefreshIndicator(
            color: AppColors.brandPink,
            onRefresh: () => profileProv.fetchProfile(token),
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
                              const Icon(Icons.person_outline_rounded, color: AppColors.brandPink, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Profile',
                                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your vendor business account',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.brandPink),
                        onPressed: () => profileProv.fetchProfile(token),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Logo / Avatar Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.lightGrey),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.brandPink.withValues(alpha: 0.15),
                          backgroundImage: profile?.logoUrl != null && profile!.logoUrl!.isNotEmpty
                              ? NetworkImage(profile.logoUrl!)
                              : null,
                          child: (profile?.logoUrl == null || profile!.logoUrl!.isEmpty)
                              ? Text(
                                  profile?.name.isNotEmpty == true ? profile!.name[0].toUpperCase() : 'V',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.brandPink,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile?.name ?? 'Vendor Business',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (profile?.contactEmail != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            profile!.contactEmail!,
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Profile Completion Progress Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profile Completion',
                              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            Text(
                              '$percent%',
                              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold, color: percent >= 80 ? AppColors.successGreen : AppColors.brandPink),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            minHeight: 6,
                            backgroundColor: AppColors.lightGrey,
                            valueColor: AlwaysStoppedAnimation<Color>(percent >= 80 ? AppColors.successGreen : AppColors.brandPink),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...checklist.map((chk) {
                          final done = chk['done'] as bool;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Icon(
                                  done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  size: 15,
                                  color: done ? AppColors.successGreen : AppColors.textLight,
                                ),
                                const SizedBox(width: 8),
                                Text(chk['label'] as String, style: GoogleFonts.inter(fontSize: 11, color: done ? AppColors.textDark : AppColors.textMedium)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Business Details Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Information',
                          style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 16),

                        // Business Name
                        _buildInputField('Business Name', _nameController, Icons.storefront_outlined),
                        const SizedBox(height: 14),

                        // Phone
                        _buildInputField('Contact Phone', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
                        const SizedBox(height: 14),

                        // City
                        _buildInputField('City', _cityController, Icons.location_city_outlined),
                        const SizedBox(height: 14),

                        // Address
                        _buildInputField('Address / Operating Location', _addressController, Icons.map_outlined),
                        const SizedBox(height: 14),

                        // Description
                        _buildInputField(
                          'Business Description / About Us',
                          _descriptionController,
                          Icons.description_outlined,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 20),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: profileProv.isSaving
                                ? null
                                : () async {
                                    final name = _nameController.text.trim();
                                    if (name.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter business name')),
                                      );
                                      return;
                                    }

                                    final ok = await profileProv.saveProfile(
                                      token,
                                      name: name,
                                      phone: _phoneController.text.trim(),
                                      city: _cityController.text.trim(),
                                      address: _addressController.text.trim(),
                                      description: _descriptionController.text.trim(),
                                    );

                                    if (ok && mounted) {
                                      context.read<VendorPortalProvider>().loadProfile(token);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Profile saved successfully!')),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandPink,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: profileProv.isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    'Save Changes',
                                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Change Password Section Matching React
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security & Password',
                          style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 16),
                        _buildInputField('Current Password', _currentPwController, Icons.lock_outline, isPassword: true),
                        const SizedBox(height: 14),
                        _buildInputField('New Password', _newPwController, Icons.lock_reset_outlined, isPassword: true),
                        const SizedBox(height: 14),
                        _buildInputField('Confirm New Password', _confirmPwController, Icons.lock_reset_outlined, isPassword: true),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton(
                            onPressed: profileProv.isChangingPassword
                                ? null
                                : () async {
                                    final cur = _currentPwController.text.trim();
                                    final np = _newPwController.text.trim();
                                    final cnp = _confirmPwController.text.trim();

                                    if (cur.isEmpty || np.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter current and new passwords')),
                                      );
                                      return;
                                    }
                                    if (np != cnp) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('New passwords do not match')),
                                      );
                                      return;
                                    }

                                    final ok = await profileProv.changePassword(token, currentPassword: cur, newPassword: np);
                                    if (ok && mounted) {
                                      _currentPwController.clear();
                                      _newPwController.clear();
                                      _confirmPwController.clear();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Password changed successfully!')),
                                      );
                                    }
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.brandPink,
                              side: const BorderSide(color: AppColors.brandPink),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: profileProv.isChangingPassword
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text('Change Password', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.brandPink, size: 18) : null,
            filled: true,
            fillColor: AppColors.lightBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brandPink),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
