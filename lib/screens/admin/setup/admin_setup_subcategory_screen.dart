import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth/admin_auth_provider.dart';
import '../../../providers/admin/admin_subcategory_provider.dart';
import '../../../models/subcategory/admin_subcategory_model.dart';
import '../../../utils/colors/app_colors.dart';

class AdminSetupSubcategoryScreen extends StatefulWidget {
  const AdminSetupSubcategoryScreen({super.key});

  @override
  State<AdminSetupSubcategoryScreen> createState() => _AdminSetupSubcategoryScreenState();
}

class _AdminSetupSubcategoryScreenState extends State<AdminSetupSubcategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

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

  String get _token => context.read<AdminAuthProvider>().token ?? '';

  Future<void> _loadData() async {
    await context.read<AdminSubcategoryProvider>().loadSubcategories(_token);
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.redAccent : AppColors.successGreen),
    );
  }

  void _openSubcategoryDialog({AdminSubcategoryModel? existing}) {
    final provider = context.read<AdminSubcategoryProvider>();
    final nameCtrl = TextEditingController(text: existing?.subcategoryName ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final priceCtrl = TextEditingController(text: existing?.basePrice != null ? existing!.basePrice.toString() : '');
    String? selectedCategoryId = existing?.categoryId ?? (provider.categories.isNotEmpty ? provider.categories.first.id : null);
    bool isActive = existing?.isActive ?? true;
    XFile? pickedImage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> pickImage() async {
              final source = await showModalBottomSheet<ImageSource>(
                context: dialogContext,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (ctx) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_library_outlined, color: AppColors.brandPink),
                          title: const Text('Photo Gallery'),
                          onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt_outlined, color: AppColors.brandPink),
                          title: const Text('Camera'),
                          onTap: () => Navigator.pop(ctx, ImageSource.camera),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              if (source == null) return;
              final img = await ImagePicker().pickImage(source: source, imageQuality: 85);
              if (img != null) setDialogState(() => pickedImage = img);
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                existing == null ? 'Add New Subcategory' : 'Edit Subcategory',
                style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedCategoryId,
                        decoration: const InputDecoration(labelText: 'Parent Category'),
                        items: provider.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (val) => setDialogState(() => selectedCategoryId = val),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Subcategory Name'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Base Price (PKR)',
                          helperText: "Shown as 'From PKR …'. Leave blank for 'Price on request'.",
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderGrey),
                          ),
                          child: pickedImage != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(pickedImage!.path), fit: BoxFit.cover))
                              : existing?.imageUrl != null && existing!.imageUrl!.isNotEmpty
                                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(existing.imageUrl!, fit: BoxFit.cover))
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.textLight),
                                        const SizedBox(height: 4),
                                        Text('Subcategory Image', style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textLight)),
                                      ],
                                    ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Active Status',
                                  style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                            ),
                            Switch(value: isActive, activeColor: AppColors.successGreen, onChanged: (v) => setDialogState(() => isActive = v)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                Consumer<AdminSubcategoryProvider>(
                  builder: (context, prov, _) => ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPink, foregroundColor: Colors.white),
                    onPressed: prov.isSaving
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty || selectedCategoryId == null) {
                              _showSnack('Subcategory name and parent category are required.', isError: true);
                              return;
                            }
                            if (provider.isDuplicateName(name, excludeId: existing?.id)) {
                              _showSnack('A subcategory named "$name" already exists.', isError: true);
                              return;
                            }
                            String? error;
                            if (existing == null) {
                              error = await provider.createSubcategory(
                                _token,
                                categoryId: selectedCategoryId!,
                                subcategoryName: name,
                                description: descCtrl.text.trim(),
                                isActive: isActive,
                                basePrice: priceCtrl.text.trim(),
                                imagePath: pickedImage?.path,
                              );
                            } else {
                              error = await provider.updateSubcategory(
                                _token,
                                id: existing.id,
                                categoryId: selectedCategoryId!,
                                subcategoryName: name,
                                description: descCtrl.text.trim(),
                                isActive: isActive,
                                basePrice: priceCtrl.text.trim(),
                                imagePath: pickedImage?.path,
                              );
                            }
                            if (dialogContext.mounted) Navigator.pop(dialogContext);
                            if (error != null) {
                              _showSnack(error, isError: true);
                            } else {
                              _showSnack(existing == null ? 'Subcategory created.' : 'Subcategory updated.');
                            }
                          },
                    child: prov.isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(existing == null ? 'Create Subcategory' : 'Update Subcategory'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(AdminSubcategoryModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Subcategory'),
        content: Text('Delete "${item.subcategoryName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await context.read<AdminSubcategoryProvider>().deleteSubcategory(_token, item.id);
    _showSnack(error ?? 'Subcategory deleted.', isError: error != null);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminSubcategoryProvider>();
    final canEdit = context.read<AdminAuthProvider>().hasPermission('services');

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.setSearch(val),
              decoration: InputDecoration(
                hintText: 'Search subcategories...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.cardWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.borderGrey)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All Categories', provider.filterCategoryId == null, () => provider.setFilterCategory(null)),
                  ...provider.categories.map((c) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _buildFilterChip(c.name, provider.filterCategoryId == c.id, () => provider.setFilterCategory(c.id)),
                      )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Showing ${provider.subcategories.length} of ${provider.totalCount} subcategories',
                style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(provider.error!, style: const TextStyle(color: Colors.redAccent)),
            ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.subcategories.isEmpty
                    ? Center(
                        child: Text(
                          'No subcategories found.',
                          style: GoogleFonts.montserrat(color: AppColors.textMedium),
                        ),
                      )
                    : Stack(
                        children: [
                          ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: provider.subcategories.length,
                            itemBuilder: (context, index) {
                              final item = provider.subcategories[index];
                              final isSelected = _selectedIds.contains(item.id);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                color: AppColors.cardWhite,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(value: isSelected, onChanged: (_) => _toggleSelect(item.id)),
                                      if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            item.imageUrl!,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 48,
                                              height: 48,
                                              color: AppColors.lightGrey,
                                              child: const Icon(Icons.image_not_supported_outlined, size: 18),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.subcategoryName,
                                              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                                            ),
                                            if (item.categoryName != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.lightGrey,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: AppColors.borderGrey),
                                                  ),
                                                  child: Text(item.categoryName!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: item.basePrice != null
                                                  ? Text('PKR ${item.basePrice!.toStringAsFixed(0)}',
                                                      style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryGold))
                                                  : Text('Price on request',
                                                      style: GoogleFonts.montserrat(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textLight)),
                                            ),
                                            if ((item.description ?? '').isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  item.description!,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMedium),
                                                ),
                                              ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: item.isActive ? AppColors.successGreen.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  item.isActive ? 'Active' : 'Inactive',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: item.isActive ? AppColors.successGreen : Colors.redAccent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Switch(
                                            value: item.isActive,
                                            activeColor: AppColors.successGreen,
                                            onChanged: (_) => provider.toggleActive(_token, item),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _openSubcategoryDialog(existing: item);
                                              } else if (value == 'delete') {
                                                _confirmDelete(item);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.redAccent))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (canEdit)
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: FloatingActionButton.extended(
                                heroTag: null,
                                backgroundColor: AppColors.brandPink,
                                icon: const Icon(Icons.add_outlined, color: Colors.white),
                                label: Text('Add Subcategory', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
                                onPressed: () => _openSubcategoryDialog(),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      selectedColor: AppColors.brandPink.withOpacity(0.2),
      onSelected: (_) => onTap(),
    );
  }
}
