/// Vendor Service & Catalog Hierarchy Models
class VendorServiceModel {
  final int serviceId;
  final String serviceName;
  final List<VendorCategoryGroupModel> categories;

  const VendorServiceModel({
    required this.serviceId,
    required this.serviceName,
    required this.categories,
  });

  factory VendorServiceModel.fromJson(Map<String, dynamic> json) {
    return VendorServiceModel(
      serviceId: json['service_id'] is int ? json['service_id'] : int.tryParse(json['service_id']?.toString() ?? '0') ?? 0,
      serviceName: json['service_name']?.toString() ?? '',
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((c) => VendorCategoryGroupModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VendorCategoryGroupModel {
  final int categoryId;
  final String categoryName;
  final String? subServiceName;
  final List<VendorSubcategoryModel> subcategories;

  const VendorCategoryGroupModel({
    required this.categoryId,
    required this.categoryName,
    this.subServiceName,
    required this.subcategories,
  });

  factory VendorCategoryGroupModel.fromJson(Map<String, dynamic> json) {
    return VendorCategoryGroupModel(
      categoryId: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      categoryName: json['category_name']?.toString() ?? '',
      subServiceName: json['sub_service_name']?.toString(),
      subcategories: (json['subcategories'] as List<dynamic>? ?? [])
          .map((sc) => VendorSubcategoryModel.fromJson(sc as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VendorSubcategoryModel {
  final int id;
  final String name;
  final String? description;
  final double? price;
  final int? minGuests;
  final int? maxGuests;
  final String? capacityNotes;
  final String? imageUrl;
  final String approvalStatus;
  final bool isActive;
  final String? serviceName;
  final String? categoryName;

  const VendorSubcategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.minGuests,
    this.maxGuests,
    this.capacityNotes,
    this.imageUrl,
    this.approvalStatus = 'approved',
    this.isActive = true,
    this.serviceName,
    this.categoryName,
  });

  factory VendorSubcategoryModel.fromJson(Map<String, dynamic> json) {
    double? parsedPrice;
    if (json['price'] != null) {
      parsedPrice = double.tryParse(json['price'].toString());
    }

    int? minG = json['min_guests'] != null ? int.tryParse(json['min_guests'].toString()) : null;
    int? maxG = json['max_guests'] != null ? int.tryParse(json['max_guests'].toString()) : null;

    return VendorSubcategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: parsedPrice,
      minGuests: minG,
      maxGuests: maxG,
      capacityNotes: json['capacity_notes']?.toString(),
      imageUrl: json['image_url']?.toString(),
      approvalStatus: json['approval_status']?.toString() ?? 'approved',
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
      serviceName: json['service_name']?.toString(),
      categoryName: json['category_name']?.toString(),
    );
  }

  VendorSubcategoryModel copyWith({
    double? price,
    int? minGuests,
    int? maxGuests,
    String? capacityNotes,
    String? imageUrl,
    String? approvalStatus,
    bool? isActive,
  }) {
    return VendorSubcategoryModel(
      id: id,
      name: name,
      description: description,
      price: price ?? this.price,
      minGuests: minGuests ?? this.minGuests,
      maxGuests: maxGuests ?? this.maxGuests,
      capacityNotes: capacityNotes ?? this.capacityNotes,
      imageUrl: imageUrl ?? this.imageUrl,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      isActive: isActive ?? this.isActive,
      serviceName: serviceName,
      categoryName: categoryName,
    );
  }
}

/// Blackout Date Model
class VendorBlackoutDateModel {
  final int id;
  final String date;
  final String? reason;

  const VendorBlackoutDateModel({
    required this.id,
    required this.date,
    this.reason,
  });

  factory VendorBlackoutDateModel.fromJson(Map<String, dynamic> json) {
    return VendorBlackoutDateModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      date: json['date']?.toString() ?? '',
      reason: json['reason']?.toString(),
    );
  }
}

/// Service Request Model (Link / Unlink)
class VendorServiceRequestModel {
  final int id;
  final String requestType; // 'link' or 'unlink'
  final int subcategoryId;
  final String? subcategoryName;
  final String? categoryName;
  final String status; // 'pending', 'approved', 'rejected'
  final String? reason;
  final String? adminNote;
  final DateTime? createdAt;

  const VendorServiceRequestModel({
    required this.id,
    required this.requestType,
    required this.subcategoryId,
    this.subcategoryName,
    this.categoryName,
    required this.status,
    this.reason,
    this.adminNote,
    this.createdAt,
  });

  factory VendorServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return VendorServiceRequestModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      requestType: json['request_type']?.toString() ?? 'link',
      subcategoryId: json['subcategory_id'] is int
          ? json['subcategory_id']
          : int.tryParse(json['subcategory_id']?.toString() ?? '0') ?? 0,
      subcategoryName: json['subcategory_name']?.toString() ?? json['name']?.toString(),
      categoryName: json['category_name']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      reason: json['reason']?.toString(),
      adminNote: json['admin_note']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  bool get isCancelled =>
      status == 'rejected' && (adminNote ?? '').toLowerCase().contains('cancelled');
}

/// Vendor Profile Model
class VendorProfileModel {
  final int? id;
  final String name;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final String? city;
  final String? description;
  final String? logoUrl;

  const VendorProfileModel({
    this.id,
    required this.name,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.city,
    this.description,
    this.logoUrl,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    return VendorProfileModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      contactEmail: json['contact_email']?.toString() ?? json['email']?.toString(),
      contactPhone: json['contact_phone']?.toString() ?? json['phone']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      description: json['description']?.toString(),
      logoUrl: json['logo_url']?.toString() ?? json['logo']?.toString(),
    );
  }

  Map<String, String> toFields() => {
        'name': name.trim(),
        'contact_phone': contactPhone?.trim() ?? '',
        'address': address?.trim() ?? '',
        'city': city?.trim() ?? '',
        'description': description?.trim() ?? '',
      };
}
