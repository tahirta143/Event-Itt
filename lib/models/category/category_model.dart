class CategoryModel {
  final String id;
  final String title;
  final String imageUrl;
  final int itemQuantity;
  final bool isSelected;

  CategoryModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.itemQuantity = 0,
    this.isSelected = false,
  });

  CategoryModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    int? itemQuantity,
    bool? isSelected,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      itemQuantity: itemQuantity ?? this.itemQuantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
