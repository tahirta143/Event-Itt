/// Customer returned by POST /api/customer/auth/verify-otp
/// and GET /api/admin/customers.
class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String? phone;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  String get customerName => name;
  String get customerEmail => email;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
      };

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
