import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/booking/booking_model.dart';
import '../../models/vendor/vendor_models.dart';

/// Comprehensive Vendor Portal Provider for dashboard KPIs, recent data, and overview state.
class VendorPortalProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Stats
  int totalBookings = 0;
  int pendingBookings = 0;
  int confirmedBookings = 0;
  int activeServicesCount = 0;
  double totalRevenue = 0.0;
  double monthRevenue = 0.0;
  Map<String, dynamic> _insights = {};

  // Data collections
  List<BookingModel> _bookings = [];
  List<VendorServiceModel> _serviceHierarchy = [];
  List<VendorSubcategoryModel> _flatServices = [];
  List<VendorServiceRequestModel> _serviceRequests = [];
  List<VendorBlackoutDateModel> _blackoutDates = [];
  VendorProfileModel? _profile;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int get upcomingCount {
    final now = DateTime.now();
    final todayStr = _dateStr(now);
    final in30Str = _dateStr(now.add(const Duration(days: 30)));
    return _bookings.where((b) {
      if (b.eventDate == null) return false;
      return b.eventDate!.compareTo(todayStr) >= 0 &&
          b.eventDate!.compareTo(in30Str) <= 0 &&
          ['pending', 'confirmed', 'preparing', 'in_progress'].contains(b.status.toLowerCase());
    }).length;
  }

  int get monthCount {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return _bookings.where((b) => b.eventDate != null && b.eventDate!.startsWith(monthKey)).length;
  }

  List<BookingModel> get upcomingBookings {
    final now = DateTime.now();
    final todayStr = _dateStr(now);
    final list = _bookings.where((b) {
      if (b.eventDate == null) return false;
      return b.eventDate!.compareTo(todayStr) >= 0 &&
          !['cancelled', 'completed'].contains(b.status.toLowerCase());
    }).toList();
    list.sort((a, b) => (a.eventDate ?? '').compareTo(b.eventDate ?? ''));
    if (list.isEmpty && _bookings.isNotEmpty) {
      // Fallback to latest bookings if all are in past
      return _bookings.take(5).toList();
    }
    return list.take(5).toList();
  }

  // Booking Insights calculations
  Map<String, int> get statusBreakdown {
    final Map<String, int> map = {};
    for (var b in _bookings) {
      map[b.status] = (map[b.status] ?? 0) + 1;
    }
    return map;
  }

  double get avgPricePerOffering {
    final priced = _flatServices.where((s) => s.price != null && s.price! > 0).map((s) => s.price!).toList();
    if (priced.isEmpty) return 0.0;
    return priced.reduce((a, b) => a + b) / priced.length;
  }

  List<Map<String, dynamic>> get topOfferings {
    final Map<String, int> counts = {};
    for (var b in _bookings) {
      final name = b.subcategoryName ?? b.serviceName ?? 'Service';
      counts[name] = (counts[name] ?? 0) + 1;
    }
    final list = counts.entries.map((e) => {'name': e.key, 'count': e.value}).toList();
    list.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return list.take(5).toList();
  }

  List<Map<String, dynamic>> get bookingsByEventType {
    final Map<String, int> map = {};
    for (var b in _bookings) {
      final evType = b.eventType ?? b.eventLabel ?? 'other';
      map[evType] = (map[evType] ?? 0) + 1;
    }
    return map.entries.map((e) => {'event_type': e.key, 'count': e.value}).toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }

  List<BookingModel> get bookings => _bookings;
  List<VendorServiceModel> get serviceHierarchy => _serviceHierarchy;
  List<VendorSubcategoryModel> get flatServices => _flatServices;
  List<VendorServiceRequestModel> get serviceRequests => _serviceRequests;
  List<VendorBlackoutDateModel> get blackoutDates => _blackoutDates;
  VendorProfileModel? get profile => _profile;
  Map<String, dynamic> get insights => _insights;

  // Backward compatibility for existing UI
  List<Map<String, dynamic>> get services => _flatServices.map((s) => {
    'id': s.id.toString(),
    'name': s.name,
    'categoryName': s.categoryName ?? s.serviceName ?? '',
    'price': s.price != null ? s.price!.toStringAsFixed(0) : '',
    'image': s.imageUrl,
  }).toList();

  /// Profile completion score (0 - 100)
  int get profileCompletionPercentage {
    int score = 0;
    int totalChecks = 6;
    if (_profile != null && _profile!.name.trim().isNotEmpty) score++;
    if (_profile != null && (_profile!.contactPhone?.isNotEmpty == true || _profile!.contactEmail?.isNotEmpty == true)) score++;
    if (_flatServices.isNotEmpty) score++;
    if (_flatServices.any((s) => s.price != null && s.price! > 0)) score++;
    if (_flatServices.any((s) => s.minGuests != null || s.maxGuests != null)) score++;
    if (_profile != null && (_profile!.description?.trim().isNotEmpty == true)) score++;
    return ((score / totalChecks) * 100).round();
  }

  List<Map<String, dynamic>> get profileChecks {
    return [
      {'key': 'business_info', 'label': 'Business information', 'complete': _profile?.name.trim().isNotEmpty == true},
      {'key': 'contact_info', 'label': 'Contact information', 'complete': _profile?.contactPhone?.isNotEmpty == true || _profile?.contactEmail?.isNotEmpty == true},
      {'key': 'services', 'label': 'Services linked', 'complete': _flatServices.isNotEmpty},
      {'key': 'pricing', 'label': 'Pricing configured', 'complete': _flatServices.any((s) => s.price != null && s.price! > 0)},
      {'key': 'capacity', 'label': 'Capacity configured', 'complete': _flatServices.any((s) => s.minGuests != null || s.maxGuests != null)},
      {'key': 'description', 'label': 'Business description', 'complete': _profile?.description?.trim().isNotEmpty == true},
    ];
  }

  Future<void> loadStats(String token) async {
    if (SecureStorage.isMockOrInvalidToken(token)) return;

    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/stats');
    if (res.success && res.data != null) {
      final data = res.data is Map ? res.data as Map<String, dynamic> : <String, dynamic>{};
      _insights = data;
      totalBookings = _parseInt(data['totalBookings'] ?? data['total'] ?? data['total_bookings']);
      pendingBookings = _parseInt(data['pendingBookings'] ?? data['pending'] ?? data['pending_bookings']);
      confirmedBookings = _parseInt(data['confirmedBookings'] ?? data['confirmed'] ?? data['confirmed_bookings']);
      totalRevenue = _parseDouble(data['totalRevenue'] ?? data['revenue'] ?? data['total_revenue']);
      notifyListeners();
    }
  }

  Future<void> loadAll(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadStats(token),
        loadBookings(token),
        loadServices(token),
        loadRequests(token),
        loadBlackouts(token),
        loadProfile(token),
      ]);
    } catch (e) {
      _error = 'Failed to load vendor portal data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBookings(String token) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/bookings');
    if (res.success && res.data != null) {
      final data = res.data;
      List<dynamic> rawList = data is List
          ? data
          : (data is Map ? (data['bookings'] ?? data['data'] ?? []) : []);
      
      _bookings = rawList
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (totalBookings == 0 && _bookings.isNotEmpty) {
        totalBookings = _bookings.length;
        pendingBookings = _bookings.where((b) => b.status.toLowerCase() == 'pending').length;
        confirmedBookings = _bookings.where((b) => b.status.toLowerCase() == 'confirmed').length;
        totalRevenue = _bookings.where((b) => b.status.toLowerCase() != 'cancelled').fold<double>(0.0, (sum, b) => sum + (b.estimatedValue ?? b.totalAmount ?? 0.0));
      }

      final now = DateTime.now();
      final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      monthRevenue = _bookings.where((b) => b.eventDate != null && b.eventDate!.startsWith(monthKey) && b.status.toLowerCase() != 'cancelled').fold<double>(0.0, (sum, b) => sum + (b.estimatedValue ?? b.totalAmount ?? 0.0));

      notifyListeners();
    }
  }

  Future<void> loadServices(String token) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/my-services');
    if (res.success && res.data != null) {
      final data = res.data;
      if (data is Map && data['services'] is List) {
        _serviceHierarchy = (data['services'] as List)
            .map((s) => VendorServiceModel.fromJson(s as Map<String, dynamic>))
            .toList();

        final List<VendorSubcategoryModel> flat = [];
        for (var svc in _serviceHierarchy) {
          for (var cat in svc.categories) {
            for (var sub in cat.subcategories) {
              flat.add(sub.copyWith());
            }
          }
        }
        _flatServices = flat;
        activeServicesCount = flat.where((s) => s.isActive && s.approvalStatus == 'approved').length;
        notifyListeners();
      }
    }
  }

  Future<void> loadRequests(String token) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/service-requests');
    if (res.success && res.data != null) {
      final data = res.data;
      List<dynamic> rawList = data is List
          ? data
          : (data is Map ? (data['requests'] ?? data['data'] ?? []) : []);
      
      _serviceRequests = rawList
          .map((e) => VendorServiceRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> loadBlackouts(String token) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/blackout-dates');
    if (res.success && res.data != null) {
      final data = res.data;
      List<dynamic> rawList = data is List
          ? data
          : (data is Map ? (data['days'] ?? data['data'] ?? []) : []);
      
      _blackoutDates = rawList
          .map((e) => VendorBlackoutDateModel.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> loadProfile(String token) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/me');
    if (res.success && res.data != null) {
      final data = res.data;
      final vendorMap = data is Map ? (data['vendor'] ?? data) : null;
      if (vendorMap is Map<String, dynamic>) {
        _profile = VendorProfileModel.fromJson(vendorMap);
        notifyListeners();
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
    return res.error ?? 'Failed to update booking status';
  }

  int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}
