/// Model for the admin "Setup Catalog → Subcategories" screen.
/// Mirrors the `subcategories` table returned by GET /api/subcategories.
class AdminSubcategoryModel {
  final String id;
  final String categoryId;
  final String? categoryName;
  final String subcategoryName;
  final String? description;
  final String? imageUrl;
  final double? basePrice;
  final bool isActive;

  AdminSubcategoryModel({
    required this.id,
    required this.categoryId,
    this.categoryName,
    required this.subcategoryName,
    this.description,
    this.imageUrl,
    this.basePrice,
    this.isActive = true,
  });

  factory AdminSubcategoryModel.fromJson(Map<String, dynamic> json) {
    return AdminSubcategoryModel(
      id: (json['id'] ?? '').toString(),
      categoryId: (json['category_id'] ?? '').toString(),
      categoryName: json['category_name']?.toString(),
      subcategoryName: (json['subcategory_name'] ?? '').toString(),
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      basePrice: json['base_price'] != null ? double.tryParse(json['base_price'].toString()) : null,
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
    );
  }

  AdminSubcategoryModel copyWith({bool? isActive}) {
    return AdminSubcategoryModel(
      id: id,
      categoryId: categoryId,
      categoryName: categoryName,
      subcategoryName: subcategoryName,
      description: description,
      imageUrl: imageUrl,
      basePrice: basePrice,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Minimal category reference used to populate the parent dropdown
/// (GET /api/categories).
class CategoryOption {
  final String id;
  final String name;

  CategoryOption({required this.id, required this.name});

  factory CategoryOption.fromJson(Map<String, dynamic> json) {
    return CategoryOption(
      id: (json['id'] ?? '').toString(),
      name: (json['category_name'] ?? '').toString(),
    );
  }
}
