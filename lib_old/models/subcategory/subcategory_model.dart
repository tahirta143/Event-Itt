class SubCategoryModel {
  final String id;
  final String categoryId;
  final String title;
  final String imageUrl;
  final int count;

  SubCategoryModel({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.imageUrl,
    this.count = 0,
  });
}
