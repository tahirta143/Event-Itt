/// Vendor returned by POST /api/vendor/auth/login and GET /api/vendor/me.
class VendorAuthModel {
  final String id;
  final String name;
  final String email;
  final String businessName;
  final String status;
  final String? logo;
  final String? phone;
  final String? description;

  const VendorAuthModel({
    required this.id,
    required this.name,
    required this.email,
    required this.businessName,
    required this.status,
    this.logo,
    this.phone,
    this.description,
  });

  factory VendorAuthModel.fromJson(Map<String, dynamic> json) {
    return VendorAuthModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      businessName: json['businessName']?.toString() ?? json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      logo: json['logo']?.toString(),
      phone: json['phone']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'businessName': businessName,
        'status': status,
        'logo': logo,
        'phone': phone,
        'description': description,
      };

  VendorAuthModel copyWith({
    String? id,
    String? name,
    String? email,
    String? businessName,
    String? status,
    String? logo,
    String? phone,
    String? description,
  }) {
    return VendorAuthModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      businessName: businessName ?? this.businessName,
      status: status ?? this.status,
      logo: logo ?? this.logo,
      phone: phone ?? this.phone,
      description: description ?? this.description,
    );
  }
}
