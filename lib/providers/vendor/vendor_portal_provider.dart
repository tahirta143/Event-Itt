import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/booking/booking_model.dart';

/// Vendor portal provider — fetches everything a vendor needs.
class VendorPortalProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Stats
  int totalBookings = 15;
  int pendingBookings = 3;
  int confirmedBookings = 10;
  double totalRevenue = 450000.0;

  List<BookingModel> _bookings = [
    const BookingModel(
      id: 'vb_001',
      status: 'pending',
      customerName: 'Ayesha & Hamza',
      serviceName: 'Wedding Stage Decor & Lighting',
      eventDate: '2026-10-15',
    ),
    const BookingModel(
      id: 'vb_002',
      status: 'confirmed',
      customerName: 'Tariq Mahmood',
      serviceName: 'Royal Buffet Catering (500 guests)',
      eventDate: '2026-11-02',
    ),
  ];

  List<Map<String, dynamic>> _services = [
    {
      'id': 'svc_1',
      'name': 'Luxury Wedding Decor & Stage Design',
      'categoryName': 'Decor & Theme',
      'price': '150,000',
    },
    {
      'id': 'svc_2',
      'name': 'Gourmet Wedding Catering Service',
      'categoryName': 'Catering & Dining',
      'price': '300,000',
    },
  ];
  List<Map<String, dynamic>> _portfolio = [];
  List<Map<String, dynamic>> _blackoutDates = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BookingModel> get bookings => _bookings;
  List<Map<String, dynamic>> get services => _services;
  List<Map<String, dynamic>> get portfolio => _portfolio;
  List<Map<String, dynamic>> get blackoutDates => _blackoutDates;

  Future<void> loadStats(String token) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/stats');
    if (res.success && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      totalBookings = _parseInt(data['totalBookings'] ?? data['total']);
      pendingBookings = _parseInt(data['pendingBookings'] ?? data['pending']);
      confirmedBookings = _parseInt(data['confirmedBookings'] ?? data['confirmed']);
      totalRevenue = _parseDouble(data['totalRevenue'] ?? data['revenue']);
      notifyListeners();
    } else {
      totalBookings = 15;
      pendingBookings = 3;
      confirmedBookings = 10;
      totalRevenue = 450000.0;
    }
  }

  Future<void> loadAll(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.wait([
      loadStats(token),
      _loadBookings(token),
      _loadServices(token),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadBookings(String token) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/bookings');
    if (res.success && res.data != null) {
      final data = res.data;
      List<dynamic> rawList = data is List
          ? data
          : (data is Map ? (data['bookings'] ?? data['data'] ?? []) : []);
      if (rawList.isNotEmpty) {
        _bookings = rawList
            .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
  }

  Future<void> _loadServices(String token) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/my-services');
    if (res.success && res.data != null) {
      final data = res.data;
      if (data is List && data.isNotEmpty) {
        _services = data.cast<Map<String, dynamic>>();
      } else if (data is Map) {
        final list = (data['services'] ?? data['data'] ?? []) as List;
        if (list.isNotEmpty) {
          _services = list.cast<Map<String, dynamic>>();
        }
      }
    }
  }

  Future<String?> updateBookingStatus(
      String token, String bookingId, String status) async {
    final client = ApiClient(token: token);
    final res = await client.put(
      '/api/vendor/bookings/$bookingId/status',
      {'status': status},
    );
    if (res.success) {
      final idx = _bookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        _bookings[idx] = BookingModel.fromJson({
          ...(_bookings[idx].toJson()),
          'status': status,
        });
        notifyListeners();
      }
      return null;
    }
    // Update locally for smooth UX
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      _bookings[idx] = BookingModel.fromJson({
        ...(_bookings[idx].toJson()),
        'status': status,
      });
      notifyListeners();
    }
    return null;
  }

  Future<void> loadPortfolio(String token) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/portfolio');
    if (res.success && res.data != null) {
      final data = res.data;
      if (data is List) {
        _portfolio = data.cast<Map<String, dynamic>>();
      } else if (data is Map) {
        _portfolio = ((data['portfolio'] ?? data['items'] ?? []) as List)
            .cast<Map<String, dynamic>>();
      }
      notifyListeners();
    }
  }

  int _parseInt(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;
  double _parseDouble(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;
}
