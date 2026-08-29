import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/vendor/vendor_models.dart';

class VendorServicesProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  List<VendorServiceModel> _services = [];
  List<VendorSubcategoryModel> _allSubcategories = [];
  List<dynamic> _catalogCategories = [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  List<VendorServiceModel> get services => _services;
  List<VendorSubcategoryModel> get allSubcategories => _allSubcategories;
  List<dynamic> get catalogCategories => _catalogCategories;

  Future<void> fetchMyServices(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/my-services');
    if (res.success && res.data != null) {
      final data = res.data;
      if (data is Map && data['services'] is List) {
        _services = (data['services'] as List)
            .map((s) => VendorServiceModel.fromJson(s as Map<String, dynamic>))
            .toList();

        final List<VendorSubcategoryModel> flat = [];
        for (var svc in _services) {
          for (var cat in svc.categories) {
            for (var sub in cat.subcategories) {
              flat.add(VendorSubcategoryModel(
                id: sub.id,
                name: sub.name,
                description: sub.description,
                price: sub.price,
                minGuests: sub.minGuests,
                maxGuests: sub.maxGuests,
                capacityNotes: sub.capacityNotes,
                imageUrl: sub.imageUrl,
                approvalStatus: sub.approvalStatus,
                isActive: sub.isActive,
                serviceName: svc.serviceName,
                categoryName: cat.categoryName,
              ));
            }
          }
        }
        _allSubcategories = flat;
      }
    } else {
      _error = res.error ?? 'Failed to load services';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCatalogCategories(String token) async {
    final client = ApiClient(token: token);
    final res = await client.get('/api/vendor/catalog-categories');
    if (res.success && res.data != null) {
      if (res.data is List) {
        _catalogCategories = res.data as List;
      } else if (res.data is Map && res.data['categories'] is List) {
        _catalogCategories = res.data['categories'] as List;
      }
      notifyListeners();
    }
  }

  Future<bool> updatePricingAndCapacity(
    String token, {
    required int subcategoryId,
    double? price,
    int? minGuests,
    int? maxGuests,
    String? capacityNotes,
    String? imageFilePath,
  }) async {
    _isSaving = true;
    notifyListeners();

    final client = ApiClient(token: token);
    ApiResponse<dynamic> res;

    if (imageFilePath != null && imageFilePath.isNotEmpty) {
      final fields = <String, String>{};
      if (price != null) fields['price'] = price.toString();
      if (minGuests != null) fields['min_guests'] = minGuests.toString();
      if (maxGuests != null) fields['max_guests'] = maxGuests.toString();
      if (capacityNotes != null) fields['capacity_notes'] = capacityNotes;

      res = await client.multipartPut(
        '/api/vendor/pricing/$subcategoryId',
        fields: fields,
        filePath: imageFilePath,
        fileField: 'image',
      );
    } else {
      final body = <String, dynamic>{
        'price': price,
        'min_guests': minGuests,
        'max_guests': maxGuests,
        'capacity_notes': capacityNotes,
      };
      res = await client.put('/api/vendor/pricing/$subcategoryId', body);
    }

    _isSaving = false;
    if (res.success) {
      await fetchMyServices(token);
      notifyListeners();
      return true;
    } else {
      _error = res.error ?? 'Failed to update pricing';
      notifyListeners();
      return false;
    }
  }
}
