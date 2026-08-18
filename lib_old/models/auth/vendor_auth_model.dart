/// Vendor returned by POST /api/vendor/auth/login and GET /api/vendor/me and GET /api/vendors.
class VendorAuthModel {
  final String id;
  final String name;
  final String email;
  final String businessName;
  final String status; // 'active', 'inactive'
  final String? logo;
  final String? phone;
  final String? description;
  final String? address;

  const VendorAuthModel({
    required this.id,
    required this.name,
    required this.email,
    required this.businessName,
    required this.status,
    this.logo,
    this.phone,
    this.description,
    this.address,
  });

  String get vendorName => name.isNotEmpty ? name : businessName;
  String get vendorEmail => email;
  String get businessAddress => address ?? description ?? '';
  bool get isActive => status == 'active' || status == '1' || status == 'true';

  factory VendorAuthModel.fromJson(Map<String, dynamic> json) {
    final active = json['is_active'];
    final statusStr = active != null
        ? (active == 1 || active == true || active == '1' ? 'active' : 'inactive')
        : (json['status']?.toString() ?? 'active');

    return VendorAuthModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['business_name']?.toString() ?? '',
      email: json['email']?.toString() ?? json['contact_email']?.toString() ?? '',
      businessName: json['businessName']?.toString() ?? json['name']?.toString() ?? '',
      status: statusStr,
      logo: json['logo']?.toString() ?? json['logo_url']?.toString(),
      phone: json['phone']?.toString() ?? json['contact_phone']?.toString(),
      description: json['description']?.toString(),
      address: json['address']?.toString() ?? json['business_address']?.toString(),
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
        'address': address,
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
    String? address,
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
      address: address ?? this.address,
    );
  }
}
