import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/venue/venue_model.dart';
import '../../models/category/category_model.dart';
import '../../models/subcategory/subcategory_model.dart';

class VenueProvider extends ChangeNotifier {
  List<VenueModel> _allVenues = [];
  List<CategoryModel> _allCategories = [];
  List<SubCategoryModel> _subCategories = [];

  bool _isLoading = false;
  bool _isLoadingMoreVenues = false;
  bool _isLoadingMoreCategories = false;
  String? _error;

  // Venue Pagination (2-3 items on scroll)
  int _currentDisplayCount = 3;
  final int _pageSize = 3;
  int _currentVenuePage = 1;
  int _totalVenuePages = 1;

  // Horizontal Category Pagination (show 5-6 initially, load more on horizontal scroll)
  int _currentCategoryDisplayCount = 6;
  final int _categoryPageSize = 4;

  String _searchQuery = '';
  String _selectedCategoryTitle = 'All';
  String _selectedSubCategoryTitle = 'All';

  bool get isLoading => _isLoading;
  bool get isLoadingMoreVenues => _isLoadingMoreVenues;
  bool get isLoadingMoreCategories => _isLoadingMoreCategories;
  String? get error => _error;

  List<VenueModel> get _filteredVenues {
    return _allVenues.where((venue) {
      final matchesSearch = venue.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          venue.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          venue.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          venue.subCategory.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategoryTitle == 'All' || venue.category.toLowerCase() == _selectedCategoryTitle.toLowerCase();
      final matchesSubCategory = _selectedSubCategoryTitle == 'All' ||
          venue.subCategory.toLowerCase() == _selectedSubCategoryTitle.toLowerCase();
      return matchesSearch && matchesCategory && matchesSubCategory;
    }).toList();
  }

  /// Paginated venues list returned to the UI (displays 3 initially, loads 3 on scroll)
  List<VenueModel> get venues {
    final filtered = _filteredVenues;
    if (_currentDisplayCount >= filtered.length) {
      return filtered;
    }
    return filtered.take(_currentDisplayCount).toList();
  }

  /// Paginated categories list returned for horizontal list view
  List<CategoryModel> get categories {
    if (_currentCategoryDisplayCount >= _allCategories.length) {
      return _allCategories;
    }
    return _allCategories.take(_currentCategoryDisplayCount).toList();
  }

  bool get hasMoreVenues {
    final filtered = _filteredVenues;
    if (_currentDisplayCount < filtered.length) return true;
    return _currentVenuePage < _totalVenuePages;
  }

  bool get hasMoreCategories {
    return _currentCategoryDisplayCount < _allCategories.length;
  }

  List<SubCategoryModel> get subCategories => _subCategories;
  String get searchQuery => _searchQuery;
  String get selectedCategoryTitle => _selectedCategoryTitle;
  String get selectedSubCategoryTitle => _selectedSubCategoryTitle;
  int get currentVenuePage => _currentVenuePage;
  int get totalVenuePages => _totalVenuePages;

  /// Main entry point to fetch initial public data (starts displaying as soon as either arrives)
  Future<void> fetchPublicData() async {
    _isLoading = true;
    _error = null;
    _currentDisplayCount = _pageSize;
    _currentCategoryDisplayCount = 6;
    notifyListeners();

    // Fire concurrently and let each notify as soon as ready
    Future.microtask(() async {
      await fetchCategories();
      if (_allVenues.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
      }
    });

    await fetchVenues(page: 1);
    _isLoading = false;
    notifyListeners();
  }

  /// Fetches real categories & subcategories from the live API.
  Future<void> fetchCategories() async {
    final client = ApiClient();
    try {
      final catRes = await client.get('/api/public/categories');
      if (catRes.success && catRes.data != null) {
        final List<dynamic> catList = catRes.data is List ? catRes.data : [];
        final List<CategoryModel> parsedCategories = [
          CategoryModel(
            id: 'all',
            title: 'All',
            imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=300&q=70',
          )
        ];
        final List<SubCategoryModel> parsedSubCategories = [];

        for (var c in catList) {
          if (c is Map<String, dynamic>) {
            final catId = c['id']?.toString() ?? '';
            final catName = c['category_name']?.toString() ?? 'Category';
            final catImg = c['image_url']?.toString() ?? '';
            final subs = (c['subcategories'] as List<dynamic>?) ?? [];

            parsedCategories.add(CategoryModel(
              id: catId,
              title: catName,
              imageUrl: catImg.isNotEmpty ? _resolveUrl(catImg) : 'https://images.unsplash.com/photo-1519741497674-611481863552?w=300&q=70',
              itemQuantity: subs.length,
            ));

            for (var s in subs) {
              if (s is Map<String, dynamic>) {
                final subImg = s['image_url']?.toString() ?? '';
                parsedSubCategories.add(SubCategoryModel(
                  id: s['id']?.toString() ?? '',
                  categoryId: catId,
                  title: s['subcategory_name']?.toString() ?? 'Subcategory',
                  imageUrl: subImg.isNotEmpty ? _resolveUrl(subImg) : 'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?w=300&q=70',
                  count: 1,
                ));
              }
            }
          }
        }
        _allCategories = parsedCategories;
        _subCategories = parsedSubCategories;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ [VenueProvider] Error fetching categories: $e');
    }
  }

  /// Fetches real vendors/venues with pagination support.
  Future<void> fetchVenues({int page = 1, bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMoreVenues) return;
      _isLoadingMoreVenues = true;
    } else {
      _currentVenuePage = page;
      _currentDisplayCount = _pageSize;
    }
    notifyListeners();

    final client = ApiClient();
    try {
      final vendorRes = await client.get('/api/public/vendors?page=$page&limit=10');
      if (vendorRes.success && vendorRes.data != null) {
        final data = vendorRes.data;
        List<dynamic> vendorList = [];
        
        if (data is Map<String, dynamic>) {
          vendorList = (data['rows'] ?? data['vendors'] ?? data['data'] ?? []) as List;
          _totalVenuePages = int.tryParse((data['totalPages'] ?? data['total_pages'] ?? '1').toString()) ?? 1;
        } else if (data is List) {
          vendorList = data;
          _totalVenuePages = 1;
        }

        final List<VenueModel> parsedVenues = [];
        for (var v in vendorList) {
          if (v is Map<String, dynamic>) {
            final logo = v['logo_url']?.toString() ?? '';
            final imgUrl = logo.isNotEmpty
                ? _resolveUrl(logo)
                : 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=500&q=70';

            final categoryNames = v['category_names']?.toString() ?? 'Venue';
            final subcategoryNames = v['subcategory_names']?.toString() ?? '';
            final count = (v['subcategory_count'] is int) ? (v['subcategory_count'] as int) : 2;

            parsedVenues.add(VenueModel(
              id: v['id']?.toString() ?? '',
              title: v['name']?.toString() ?? 'Vendor',
              location: v['address']?.toString() ?? 'Pakistan',
              price: 'Rs ${count * 75000}+',
              rating: 4.8,
              reviewsCount: count * 12,
              images: [imgUrl],
              category: categoryNames.split(',')[0].trim(),
              subCategory: subcategoryNames.isNotEmpty ? subcategoryNames.split(',')[0].trim() : 'General',
              description: v['description']?.toString() ?? 'Verified EventITT vendor.',
              capacity: '${count * 250} Guests',
            ));
          }
        }

        if (loadMore) {
          _allVenues.addAll(parsedVenues);
          _currentVenuePage++;
          _currentDisplayCount += _pageSize;
        } else {
          _allVenues = parsedVenues;
        }
      }
    } catch (e) {
      debugPrint('❌ [VenueProvider] Error fetching venues: $e');
      if (!loadMore) _error = 'Failed to load venues: $e';
    } finally {
      _isLoadingMoreVenues = false;
      notifyListeners();
    }
  }

  /// Triggers on scroll to load next batch of 2-3 venue cards
  Future<void> loadMoreVenuesOnScroll() async {
    if (_isLoadingMoreVenues) return;

    final filtered = _filteredVenues;
    if (_currentDisplayCount < filtered.length) {
      _isLoadingMoreVenues = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
      _currentDisplayCount += _pageSize;
      _isLoadingMoreVenues = false;
      notifyListeners();
    } else if (_currentVenuePage < _totalVenuePages) {
      await fetchVenues(page: _currentVenuePage + 1, loadMore: true);
    }
  }

  /// Triggers on horizontal scroll to load next batch of 4 categories
  Future<void> loadMoreCategoriesOnScroll() async {
    if (_isLoadingMoreCategories) return;
    if (_currentCategoryDisplayCount < _allCategories.length) {
      _isLoadingMoreCategories = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 250));
      _currentCategoryDisplayCount += _categoryPageSize;
      _isLoadingMoreCategories = false;
      notifyListeners();
    }
  }

  String _resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return 'https://api.eventitt.afaqmis.com$url';
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentDisplayCount = _pageSize;
    notifyListeners();
  }

  void selectCategory(String categoryTitle) {
    if (_selectedCategoryTitle == categoryTitle) {
      _selectedCategoryTitle = 'All';
    } else {
      _selectedCategoryTitle = categoryTitle;
    }
    _selectedSubCategoryTitle = 'All';
    _currentDisplayCount = _pageSize;
    notifyListeners();
  }

  void selectSubCategory(String subCategoryTitle) {
    if (_selectedSubCategoryTitle == subCategoryTitle) {
      _selectedSubCategoryTitle = 'All';
    } else {
      _selectedSubCategoryTitle = subCategoryTitle;
    }
    _currentDisplayCount = _pageSize;
    notifyListeners();
  }

  void toggleFavorite(String venueId) {
    final index = _allVenues.indexWhere((v) => v.id == venueId);
    if (index != -1) {
      _allVenues[index] = _allVenues[index].copyWith(
        isFavorite: !_allVenues[index].isFavorite,
      );
      notifyListeners();
    }
  }
}
