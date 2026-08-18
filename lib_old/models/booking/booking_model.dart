/// Booking model shared across Admin, Vendor, and Customer roles.
class BookingModel {
  final String id;
  final String status;
  final String? eventDate;
  final String? customerName;
  final String? customerEmail;
  final String? vendorName;
  final String? serviceName;
  final String? categoryName;
  final double? totalAmount;
  final String? notes;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.status,
    this.eventDate,
    this.customerName,
    this.customerEmail,
    this.vendorName,
    this.serviceName,
    this.categoryName,
    this.totalAmount,
    this.notes,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    double? amount;
    final rawAmount = json['totalAmount'] ?? json['amount'];
    if (rawAmount != null) {
      amount = double.tryParse(rawAmount.toString());
    }

    DateTime? created;
    final rawDate = json['createdAt'];
    if (rawDate != null) {
      created = DateTime.tryParse(rawDate.toString());
    }

    // customerName can be nested or flat
    String? custName = json['customerName']?.toString();
    if (custName == null && json['customer'] is Map) {
      custName = json['customer']['name']?.toString();
    }

    String? vendorNm = json['vendorName']?.toString();
    if (vendorNm == null && json['vendor'] is Map) {
      vendorNm = json['vendor']['name']?.toString() ??
          json['vendor']['businessName']?.toString();
    }

    return BookingModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      eventDate: json['eventDate']?.toString() ?? json['date']?.toString(),
      customerName: custName,
      customerEmail: json['customerEmail']?.toString() ??
          (json['customer'] is Map ? json['customer']['email']?.toString() : null),
      vendorName: vendorNm,
      serviceName: json['serviceName']?.toString() ??
          (json['service'] is Map ? json['service']['name']?.toString() : null),
      categoryName: json['categoryName']?.toString(),
      totalAmount: amount,
      notes: json['notes']?.toString(),
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'eventDate': eventDate,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'vendorName': vendorName,
        'serviceName': serviceName,
        'categoryName': categoryName,
        'totalAmount': totalAmount,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
      };

  /// Returns a user-friendly status label with capitalized first letter.
  String get statusLabel {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }
}
