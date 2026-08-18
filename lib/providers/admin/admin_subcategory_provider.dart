import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/subcategory/admin_subcategory_model.dart';

/// Admin "Setup Catalog → Subcategories" provider.
/// Mirrors client/src/pages/Subcategory.jsx exactly against the real backend:
///   GET    /api/subcategories
///   GET    /api/categories                (parent dropdown)
///   POST   /api/subcategories             (multipart: category_id, subcategory_name, description, base_price, is_active, image)
///   PUT    /api/subcategories/:id         (multipart, same fields)
///   PATCH  /api/subcategories/:id/status  { is_active }
///   DELETE /api/subcategories/:id
/// No bulk endpoint on the backend — bulk actions loop per id.
class AdminSubcategoryProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  List<AdminSubcategoryModel> _subcategories = [];
  List<CategoryOption> _categories = [];
  String _searchQuery = '';
  String? _filterCategoryId;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  List<CategoryOption> get categories => _categories;
  String get searchQuery => _searchQuery;
  String? get filterCategoryId => _filterCategoryId;
  int get totalCount => _subcategories.length;

  List<AdminSubcategoryModel> get subcategories {
    return _subcategories.where((s) {
      final matchName = s.subcategoryName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (s.description ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCat = _filterCategoryId == null || _filterCategoryId!.isEmpty || s.categoryId == _filterCategoryId;
      return matchName && matchCat;
    }).toList();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCategory(String? categoryId) {
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> loadSubcategories(String token) async {
    if (SecureStorage.isMockOrInvalidToken(token)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final client = ApiClient(token: token);
    final results = await Future.wait([
      client.get('/api/subcategories'),
      client.get('/api/categories'),
    ]);

    final subsRes = results[0];
    final catsRes = results[1];

    if (subsRes.success && subsRes.data != null) {
      _subcategories = _extractList(subsRes.data).map((e) => AdminSubcategoryModel.fromJson(e)).toList();
    } else {
      _error = subsRes.error ?? 'Failed to load subcategories.';
    }

    if (catsRes.success && catsRes.data != null) {
      _categories = _extractList(catsRes.data).map((e) => CategoryOption.fromJson(e)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    if (data is Map<String, dynamic>) {
      final rows = data['rows'] ?? data['data'];
      if (rows is List) return rows.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  bool isDuplicateName(String name, {String? excludeId}) {
    final n = name.trim().toLowerCase();
    return _subcategories.any((s) => s.subcategoryName.toLowerCase() == n && s.id != excludeId);
  }

  Future<String?> createSubcategory(
    String token, {
    required String categoryId,
    required String subcategoryName,
    required String description,
    required bool isActive,
    String? basePrice,
    String? imagePath,
  }) async {
    _isSaving = true;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.multipartPost(
      '/api/subcategories',
      fields: {
        'category_id': categoryId,
        'subcategory_name': subcategoryName,
        'description': description,
        'is_active': isActive.toString(),
        'base_price': basePrice ?? '',
      },
      filePath: imagePath,
      fileField: 'image',
    );

    String? errorMsg;
    if (res.success) {
      await loadSubcategories(token);
    } else {
      errorMsg = res.error ?? 'Failed to create subcategory.';
    }

    _isSaving = false;
    notifyListeners();
    return errorMsg;
  }

  Future<String?> updateSubcategory(
    String token, {
    required String id,
    required String categoryId,
    required String subcategoryName,
    required String description,
    required bool isActive,
    String? basePrice,
    String? imagePath,
  }) async {
    _isSaving = true;
    notifyListeners();

    final client = ApiClient(token: token);
    final res = await client.multipartPut(
      '/api/subcategories/$id',
      fields: {
        'category_id': categoryId,
        'subcategory_name': subcategoryName,
        'description': description,
        'is_active': isActive.toString(),
        'base_price': basePrice ?? '',
      },
      filePath: imagePath,
      fileField: 'image',
    );

    String? errorMsg;
    if (res.success) {
      await loadSubcategories(token);
    } else {
      errorMsg = res.error ?? 'Failed to update subcategory.';
    }

    _isSaving = false;
    notifyListeners();
    return errorMsg;
  }

  Future<String?> deleteSubcategory(String token, String id) async {
    final client = ApiClient(token: token);
    final res = await client.delete('/api/subcategories/$id');
    if (res.success) {
      _subcategories.removeWhere((s) => s.id == id);
      notifyListeners();
      return null;
    }
    return res.error ?? 'Failed to delete subcategory.';
  }

  Future<String?> toggleActive(String token, AdminSubcategoryModel subcategory) async {
    final client = ApiClient(token: token);
    final newValue = !subcategory.isActive;
    final res = await client.patch('/api/subcategories/${subcategory.id}/status', {'is_active': newValue});
    if (res.success) {
      final idx = _subcategories.indexWhere((s) => s.id == subcategory.id);
      if (idx != -1) {
        _subcategories[idx] = _subcategories[idx].copyWith(isActive: newValue);
        notifyListeners();
      }
      return null;
    }
    return res.error ?? 'Failed to update status.';
  }

  Future<void> bulkSetActive(String token, Set<String> ids, bool active) async {
    final client = ApiClient(token: token);
    for (final id in ids) {
      await client.patch('/api/subcategories/$id/status', {'is_active': active});
    }
    await loadSubcategories(token);
  }

  Future<void> bulkDelete(String token, Set<String> ids) async {
    final client = ApiClient(token: token);
    for (final id in ids) {
      await client.delete('/api/subcategories/$id');
    }
    _subcategories.removeWhere((s) => ids.contains(s.id));
    notifyListeners();
  }
}
