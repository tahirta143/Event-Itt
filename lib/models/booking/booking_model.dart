/// Booking model shared across Admin, Vendor, and Customer roles.
class BookingModel {
  final String id;
  final String status;
  final String? eventDate;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? vendorName;
  final String? serviceName;
  final String? subcategoryName;
  final String? categoryName;
  final String? eventVenue;
  final String? eventType;
  final String? eventLabel;
  final int? guestCount;
  final double? totalAmount;
  final double? estimatedValue;
  final double? depositAmount;
  final String? invoiceNumber;
  final String? paymentStatus;
  final String? specialRequests;
  final String? notes;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.status,
    this.eventDate,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.vendorName,
    this.serviceName,
    this.subcategoryName,
    this.categoryName,
    this.eventVenue,
    this.eventType,
    this.eventLabel,
    this.guestCount,
    this.totalAmount,
    this.estimatedValue,
    this.depositAmount,
    this.invoiceNumber,
    this.paymentStatus,
    this.specialRequests,
    this.notes,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    double? amount;
    final rawAmount = json['estimated_value'] ?? json['estimatedValue'] ?? json['totalAmount'] ?? json['amount'] ?? json['total_amount'];
    if (rawAmount != null) {
      amount = double.tryParse(rawAmount.toString());
    }

    double? deposit;
    final rawDeposit = json['deposit_amount'] ?? json['depositAmount'];
    if (rawDeposit != null) {
      deposit = double.tryParse(rawDeposit.toString());
    }

    int? guests;
    final rawGuests = json['guest_count'] ?? json['guestCount'] ?? json['guests'];
    if (rawGuests != null) {
      guests = int.tryParse(rawGuests.toString());
    }

    DateTime? created;
    final rawDate = json['created_at'] ?? json['createdAt'];
    if (rawDate != null) {
      created = DateTime.tryParse(rawDate.toString());
    }

    // Customer info
    String? custName = json['customer_name']?.toString() ?? json['customerName']?.toString();
    if (custName == null && json['customer'] is Map) {
      custName = json['customer']['name']?.toString();
    }

    String? custEmail = json['customer_email']?.toString() ?? json['customerEmail']?.toString();
    if (custEmail == null && json['customer'] is Map) {
      custEmail = json['customer']['email']?.toString();
    }

    String? custPhone = json['customer_phone']?.toString() ?? json['customerPhone']?.toString();
    if (custPhone == null && json['customer'] is Map) {
      custPhone = json['customer']['phone']?.toString();
    }

    // Vendor info
    String? vendorNm = json['vendor_name']?.toString() ?? json['vendorName']?.toString();
    if (vendorNm == null && json['vendor'] is Map) {
      vendorNm = json['vendor']['name']?.toString() ?? json['vendor']['businessName']?.toString();
    }

    // Service & subcategory
    final subcatName = json['subcategory_name']?.toString() ?? json['subcategoryName']?.toString();
    final svcName = json['service_name']?.toString() ?? json['serviceName']?.toString() ?? subcatName;

    // Date
    final evDate = json['event_date']?.toString() ?? json['eventDate']?.toString() ?? json['date']?.toString();

    return BookingModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      eventDate: evDate != null ? evDate.substring(0, evDate.length >= 10 ? 10 : evDate.length) : null,
      customerName: custName,
      customerEmail: custEmail,
      customerPhone: custPhone,
      vendorName: vendorNm,
      serviceName: svcName,
      subcategoryName: subcatName ?? svcName,
      categoryName: json['category_name']?.toString() ?? json['categoryName']?.toString(),
      eventVenue: json['event_venue']?.toString() ?? json['eventVenue']?.toString() ?? json['venue']?.toString(),
      eventType: json['event_type']?.toString() ?? json['eventType']?.toString(),
      eventLabel: json['event_label']?.toString() ?? json['eventLabel']?.toString(),
      guestCount: guests,
      totalAmount: amount,
      estimatedValue: amount,
      depositAmount: deposit,
      invoiceNumber: json['invoice_number']?.toString() ?? json['invoiceNumber']?.toString(),
      paymentStatus: json['payment_status']?.toString() ?? json['paymentStatus']?.toString() ?? 'unpaid',
      specialRequests: json['special_requests']?.toString() ?? json['specialRequests']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'event_date': eventDate,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'customer_phone': customerPhone,
        'vendor_name': vendorName,
        'service_name': serviceName,
        'subcategory_name': subcategoryName,
        'category_name': categoryName,
        'event_venue': eventVenue,
        'event_type': eventType,
        'guest_count': guestCount,
        'estimated_value': estimatedValue ?? totalAmount,
        'deposit_amount': depositAmount,
        'invoice_number': invoiceNumber,
        'payment_status': paymentStatus,
        'special_requests': specialRequests,
        'notes': notes,
        'created_at': createdAt?.toIso8601String(),
      };

  /// Returns a user-friendly status label with capitalized first letter.
  String get statusLabel {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
  }
}
