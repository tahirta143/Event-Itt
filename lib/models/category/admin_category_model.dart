/// Model for the admin "Setup Catalog → Categories" screen.
/// Mirrors the `categories` table returned by GET /api/categories.
class AdminCategoryModel {
  final String id;
  final String subServiceId;
  final String categoryName;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final bool isFeatured;
  final List<String> eventTypes;

  AdminCategoryModel({
    required this.id,
    required this.subServiceId,
    required this.categoryName,
    this.description,
    this.imageUrl,
    this.isActive = true,
    this.isFeatured = false,
    this.eventTypes = const [],
  });

  factory AdminCategoryModel.fromJson(Map<String, dynamic> json) {
    return AdminCategoryModel(
      id: (json['id'] ?? '').toString(),
      subServiceId: (json['sub_service_id'] ?? '').toString(),
      categoryName: (json['category_name'] ?? '').toString(),
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1 || json['is_featured'] == '1',
      eventTypes: _parseEventTypes(json['event_types']),
    );
  }

  static List<String> _parseEventTypes(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String && raw.isNotEmpty) {
      return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  AdminCategoryModel copyWith({
    String? id,
    String? subServiceId,
    String? categoryName,
    String? description,
    String? imageUrl,
    bool? isActive,
    bool? isFeatured,
    List<String>? eventTypes,
  }) {
    return AdminCategoryModel(
      id: id ?? this.id,
      subServiceId: subServiceId ?? this.subServiceId,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      eventTypes: eventTypes ?? this.eventTypes,
    );
  }
}

/// Minimal sub-service reference used to populate the parent dropdown
/// (GET /api/sub-services).
class SubServiceOption {
  final String id;
  final String name;

  SubServiceOption({required this.id, required this.name});

  factory SubServiceOption.fromJson(Map<String, dynamic> json) {
    return SubServiceOption(
      id: (json['id'] ?? '').toString(),
      name: (json['sub_service_name'] ?? '').toString(),
    );
  }
}

/// Wedding event type tags a category can be associated with.
const List<String> kCategoryEventTypes = [
  'engagement',
  'mehndi',
  'baraat',
  'walima',
  'other',
];
