import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth/admin_auth_provider.dart';
import '../../../providers/admin/admin_category_provider.dart';
import '../../../models/category/admin_category_model.dart';
import '../../../utils/colors/app_colors.dart';

class AdminSetupCategoryScreen extends StatefulWidget {
  const AdminSetupCategoryScreen({super.key});

  @override
  State<AdminSetupCategoryScreen> createState() => _AdminSetupCategoryScreenState();
}

class _AdminSetupCategoryScreenState extends State<AdminSetupCategoryScreen> {
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
    await context.read<AdminCategoryProvider>().loadCategories(_token);
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
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.successGreen,
      ),
    );
  }

  void _openCategoryDialog({AdminCategoryModel? existing}) {
    final provider = context.read<AdminCategoryProvider>();
    final nameCtrl = TextEditingController(text: existing?.categoryName ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String? selectedSubServiceId = existing?.subServiceId ??
        (provider.subServices.isNotEmpty ? provider.subServices.first.id : null);
    final Set<String> selectedEventTypes = {...(existing?.eventTypes ?? kCategoryEventTypes)};
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
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
                existing == null ? 'Add New Category' : 'Edit Category',
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
                        value: selectedSubServiceId,
                        decoration: const InputDecoration(labelText: 'Parent Sub-Service'),
                        items: provider.subServices
                            .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                            .toList(),
                        onChanged: (val) => setDialogState(() => selectedSubServiceId = val),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Category Name'),
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
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(pickedImage!.path), fit: BoxFit.cover),
                                )
                              : existing?.imageUrl != null && existing!.imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(existing.imageUrl!, fit: BoxFit.cover),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.textLight),
                                        const SizedBox(height: 4),
                                        Text('Category Image', style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textLight)),
                                      ],
                                    ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Applicable Wedding Events',
                        style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Categories tagged here appear when a matching wedding event is selected.',
                        style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: kCategoryEventTypes.map((type) {
                          final selected = selectedEventTypes.contains(type);
                          return FilterChip(
                            label: Text(type),
                            selected: selected,
                            selectedColor: AppColors.brandPink.withOpacity(0.2),
                            onSelected: (val) {
                              setDialogState(() {
                                if (val) {
                                  selectedEventTypes.add(type);
                                } else {
                                  selectedEventTypes.remove(type);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Active Status',
                                  style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                            ),
                            Switch(
                              value: isActive,
                              activeColor: AppColors.successGreen,
                              onChanged: (v) => setDialogState(() => isActive = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                Consumer<AdminCategoryProvider>(
                  builder: (context, prov, _) => ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPink, foregroundColor: Colors.white),
                    onPressed: prov.isSaving
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty || selectedSubServiceId == null) {
                              _showSnack('Category name and parent sub-service are required.', isError: true);
                              return;
                            }
                            if (provider.isDuplicateName(name, excludeId: existing?.id)) {
                              _showSnack('A category named "$name" already exists.', isError: true);
                              return;
                            }
                            String? error;
                            if (existing == null) {
                              error = await provider.createCategory(
                                _token,
                                subServiceId: selectedSubServiceId!,
                                categoryName: name,
                                description: descCtrl.text.trim(),
                                isActive: isActive,
                                eventTypes: selectedEventTypes.toList(),
                                imagePath: pickedImage?.path,
                              );
                            } else {
                              error = await provider.updateCategory(
                                _token,
                                id: existing.id,
                                subServiceId: selectedSubServiceId!,
                                categoryName: name,
                                description: descCtrl.text.trim(),
                                isActive: isActive,
                                eventTypes: selectedEventTypes.toList(),
                                imagePath: pickedImage?.path,
                              );
                            }
                            if (dialogContext.mounted) Navigator.pop(dialogContext);
                            if (error != null) {
                              _showSnack(error, isError: true);
                            } else {
                              _showSnack(existing == null ? 'Category created.' : 'Category updated.');
                            }
                          },
                    child: prov.isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(existing == null ? 'Create Category' : 'Update Category'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(AdminCategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category'),
        content: Text('Delete "${category.categoryName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final error = await context.read<AdminCategoryProvider>().deleteCategory(_token, category.id);
    _showSnack(error ?? 'Category deleted.', isError: error != null);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCategoryProvider>();
    final canEdit = context.read<AdminAuthProvider>().hasPermission('services');

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.setSearch(val),
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search_outlined),
                filled: true,
                fillColor: AppColors.cardWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.borderGrey)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Showing ${provider.categories.length} of ${provider.totalCount} categories',
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
                : provider.categories.isEmpty
                    ? Center(
                        child: Text(
                          provider.searchQuery.isNotEmpty ? 'No categories match your search.' : 'No categories available. Create one to get started.',
                          style: GoogleFonts.montserrat(color: AppColors.textMedium),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Stack(
                        children: [
                          ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: provider.categories.length,
                            itemBuilder: (context, index) {
                              final category = provider.categories[index];
                              final isSelected = _selectedIds.contains(category.id);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                color: AppColors.cardWhite,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(value: isSelected, onChanged: (_) => _toggleSelect(category.id)),
                                      if (category.imageUrl != null && category.imageUrl!.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            category.imageUrl!,
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
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    category.categoryName,
                                                    style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                                                  ),
                                                ),
                                                if (category.isFeatured)
                                                  const Padding(
                                                    padding: EdgeInsets.only(left: 4),
                                                    child: Icon(Icons.star_outline_rounded, size: 18, color: Colors.amber),
                                                  ),
                                              ],
                                            ),
                                            if ((category.description ?? '').isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2),
                                                child: Text(
                                                  category.description!,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textMedium),
                                                ),
                                              ),
                                            if (category.eventTypes.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6),
                                                child: Wrap(
                                                  spacing: 6,
                                                  runSpacing: 4,
                                                  children: category.eventTypes
                                                      .map((t) => Chip(
                                                            label: Text(t, style: const TextStyle(fontSize: 10)),
                                                            visualDensity: VisualDensity.compact,
                                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                            backgroundColor: AppColors.romanticPink.withOpacity(0.4),
                                                          ))
                                                      .toList(),
                                                ),
                                              ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: category.isActive ? AppColors.successGreen.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      category.isActive ? 'Active' : 'Inactive',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w700,
                                                        color: category.isActive ? AppColors.successGreen : Colors.redAccent,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () => provider.toggleFeatured(_token, category),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: category.isFeatured ? Colors.amber.withOpacity(0.15) : AppColors.lightGrey,
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text(
                                                        category.isFeatured ? 'Featured' : 'Feature',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w700,
                                                          color: category.isFeatured ? Colors.amber[800] : AppColors.textMedium,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Switch(
                                            value: category.isActive,
                                            activeColor: AppColors.successGreen,
                                            onChanged: (_) => provider.toggleActive(_token, category),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _openCategoryDialog(existing: category);
                                              } else if (value == 'delete') {
                                                _confirmDelete(category);
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
                                label: Text('Add Category', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
                                onPressed: () => _openCategoryDialog(),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
