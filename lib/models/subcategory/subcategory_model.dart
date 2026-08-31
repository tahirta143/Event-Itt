class SubCategoryModel {
  final String id;
  final String categoryId;
  final String? categoryName;
  final String title;
  final String imageUrl;
  final double? basePrice;
  final String? description;
  final int count;

  SubCategoryModel({
    required this.id,
    required this.categoryId,
    this.categoryName,
    required this.title,
    required this.imageUrl,
    this.basePrice,
    this.description,
    this.count = 0,
  });
}
