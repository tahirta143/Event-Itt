class VenueModel {
  final String id;
  final String title;
  final String location;
  final String price;
  final double rating;
  final int reviewsCount;
  final List<String> images;
  final String category;
  final String subCategory;
  final bool isFavorite;
  final String description;
  final String capacity;

  VenueModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.images,
    required this.category,
    required this.subCategory,
    this.isFavorite = false,
    required this.description,
    required this.capacity,
  });

  VenueModel copyWith({
    String? id,
    String? title,
    String? location,
    String? price,
    double? rating,
    int? reviewsCount,
    List<String>? images,
    String? category,
    String? subCategory,
    bool? isFavorite,
    String? description,
    String? capacity,
  }) {
    return VenueModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      images: images ?? this.images,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
    );
  }
}
