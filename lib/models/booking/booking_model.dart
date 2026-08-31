/// Booking model shared across Admin, Vendor, and Customer roles.
class BookingModel {
  final String id;
  final String status;
  final String? eventDate;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? vendorId;
  final String? vendorName;
  final String? serviceName;
  final String? subcategoryId;
  final String? subcategoryName;
  final String? categoryName;
  final String? eventId;
  final String? eventVenue;
  final String? eventType;
  final String? eventLabel;
  final int? guestCount;
  final double? totalAmount;
  final double? estimatedValue;
  final double? depositAmount;
  final double? totalPaid;
  final String? currency;
  final String? invoiceNumber;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? specialRequests;
  final String? notes;
  final String? reviewId;
  final int? reviewRating;
  final String? reviewComment;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.status,
    this.eventDate,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.vendorId,
    this.vendorName,
    this.serviceName,
    this.subcategoryId,
    this.subcategoryName,
    this.categoryName,
    this.eventId,
    this.eventVenue,
    this.eventType,
    this.eventLabel,
    this.guestCount,
    this.totalAmount,
    this.estimatedValue,
    this.depositAmount,
    this.totalPaid,
    this.currency,
    this.invoiceNumber,
    this.paymentStatus,
    this.paymentMethod,
    this.specialRequests,
    this.notes,
    this.reviewId,
    this.reviewRating,
    this.reviewComment,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    double? amount;
    final rawAmount = json['estimated_value'] ??
        json['estimatedValue'] ??
        json['totalAmount'] ??
        json['amount'] ??
        json['total_amount'];
    if (rawAmount != null) {
      amount = double.tryParse(rawAmount.toString());
    }

    double? deposit;
    final rawDeposit = json['deposit_amount'] ?? json['depositAmount'];
    if (rawDeposit != null) {
      deposit = double.tryParse(rawDeposit.toString());
    }

    double? paid;
    final rawPaid = json['total_paid'] ?? json['totalPaid'];
    if (rawPaid != null) {
      paid = double.tryParse(rawPaid.toString());
    }

    int? guests;
    final rawGuests =
        json['guest_count'] ?? json['guestCount'] ?? json['guests'];
    if (rawGuests != null) {
      guests = int.tryParse(rawGuests.toString());
    }

    DateTime? created;
    final rawDate = json['created_at'] ?? json['createdAt'];
    if (rawDate != null) {
      created = DateTime.tryParse(rawDate.toString());
    }

    // Customer info
    String? custName =
        json['customer_name']?.toString() ?? json['customerName']?.toString();
    if (custName == null && json['customer'] is Map) {
      custName = json['customer']['name']?.toString();
    }

    String? custEmail = json['customer_email']?.toString() ??
        json['customerEmail']?.toString();
    if (custEmail == null && json['customer'] is Map) {
      custEmail = json['customer']['email']?.toString();
    }

    String? custPhone = json['customer_phone']?.toString() ??
        json['customerPhone']?.toString();
    if (custPhone == null && json['customer'] is Map) {
      custPhone = json['customer']['phone']?.toString();
    }

    // Vendor info
    String? vId = json['vendor_id']?.toString() ?? json['vendorId']?.toString();
    String? vendorNm =
        json['vendor_name']?.toString() ?? json['vendorName']?.toString();
    if (vendorNm == null && json['vendor'] is Map) {
      vendorNm = json['vendor']['name']?.toString() ??
          json['vendor']['businessName']?.toString();
      vId ??= json['vendor']['id']?.toString();
    }

    // Service & subcategory
    final subcatId = json['subcategory_id']?.toString() ?? json['subcategoryId']?.toString();
    final subcatName = json['subcategory_name']?.toString() ??
        json['subcategoryName']?.toString();
    final svcName = json['service_name']?.toString() ??
        json['serviceName']?.toString() ??
        subcatName;

    // Date
    final evDate = json['event_date']?.toString() ??
        json['eventDate']?.toString() ??
        json['date']?.toString();

    // Review info
    final rRating = int.tryParse(json['review_rating']?.toString() ??
        json['rating']?.toString() ??
        '');

    return BookingModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      eventDate: evDate != null
          ? (evDate.length >= 10 ? evDate.substring(0, 10) : evDate)
          : null,
      customerName: custName,
      customerEmail: custEmail,
      customerPhone: custPhone,
      vendorId: vId,
      vendorName: vendorNm,
      serviceName: svcName,
      subcategoryId: subcatId,
      subcategoryName: subcatName ?? svcName,
      categoryName: json['category_name']?.toString() ??
          json['categoryName']?.toString(),
      eventId: json['event_id']?.toString() ?? json['eventId']?.toString(),
      eventVenue: json['event_venue']?.toString() ??
          json['eventVenue']?.toString() ??
          json['venue']?.toString(),
      eventType: json['event_type']?.toString() ?? json['eventType']?.toString(),
      eventLabel:
          json['event_label']?.toString() ?? json['eventLabel']?.toString(),
      guestCount: guests,
      totalAmount: amount,
      estimatedValue: amount,
      depositAmount: deposit,
      totalPaid: paid,
      currency: json['currency']?.toString() ?? 'PKR',
      invoiceNumber: json['invoice_number']?.toString() ??
          json['invoiceNumber']?.toString(),
      paymentStatus: json['payment_status']?.toString() ??
          json['paymentStatus']?.toString() ??
          'unpaid',
      paymentMethod: json['payment_method']?.toString() ??
          json['paymentMethod']?.toString(),
      specialRequests: json['special_requests']?.toString() ??
          json['specialRequests']?.toString(),
      notes: json['notes']?.toString(),
      reviewId: json['review_id']?.toString() ?? json['reviewId']?.toString(),
      reviewRating: rRating,
      reviewComment: json['review_comment']?.toString() ??
          json['reviewComment']?.toString(),
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
        'vendor_id': vendorId,
        'vendor_name': vendorName,
        'service_name': serviceName,
        'subcategory_id': subcategoryId,
        'subcategory_name': subcategoryName,
        'category_name': categoryName,
        'event_id': eventId,
        'event_venue': eventVenue,
        'event_type': eventType,
        'guest_count': guestCount,
        'estimated_value': estimatedValue ?? totalAmount,
        'deposit_amount': depositAmount,
        'total_paid': totalPaid,
        'currency': currency,
        'invoice_number': invoiceNumber,
        'payment_status': paymentStatus,
        'payment_method': paymentMethod,
        'special_requests': specialRequests,
        'notes': notes,
        'review_id': reviewId,
        'review_rating': reviewRating,
        'review_comment': reviewComment,
        'created_at': createdAt?.toIso8601String(),
      };

  /// User-friendly status label.
  String get statusLabel {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
  }

  /// Outstanding balance helper.
  double get remainingBalance {
    final total = estimatedValue ?? totalAmount ?? 0;
    final paid = totalPaid ?? (paymentStatus == 'paid' ? total : (paymentStatus == 'deposit_paid' ? (depositAmount ?? 0) : 0));
    return (total - paid) > 0 ? (total - paid) : 0;
  }

  /// Outstanding deposit helper.
  double get outstandingDeposit {
    final deposit = depositAmount ?? 0;
    final paid = totalPaid ?? 0;
    return (deposit - paid) > 0 ? (deposit - paid) : (paymentStatus == 'unpaid' ? deposit : 0);
  }
}
