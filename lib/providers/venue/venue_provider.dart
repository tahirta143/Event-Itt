import 'package:flutter/material.dart';
import '../../models/venue/venue_model.dart';
import '../../models/category/category_model.dart';
import '../../models/subcategory/subcategory_model.dart';
import '../../utils/mock_data/mock_data.dart';

class VenueProvider extends ChangeNotifier {
  List<VenueModel> _venues = List.from(MockData.venues);
  List<CategoryModel> _categories = List.from(MockData.categories);
  List<SubCategoryModel> _subCategories = List.from(MockData.subCategories);

  String _searchQuery = '';
  String _selectedCategoryTitle = 'All';
  String _selectedSubCategoryTitle = 'All';

  List<VenueModel> get venues {
    return _venues.where((venue) {
      final matchesSearch = venue.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          venue.location.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategoryTitle == 'All' || venue.category.toLowerCase() == _selectedCategoryTitle.toLowerCase();
      final matchesSubCategory = _selectedSubCategoryTitle == 'All' ||
          venue.subCategory.toLowerCase() == _selectedSubCategoryTitle.toLowerCase();
      return matchesSearch && matchesCategory && matchesSubCategory;
    }).toList();
  }

  List<CategoryModel> get categories => _categories;
  List<SubCategoryModel> get subCategories => _subCategories;
  String get searchQuery => _searchQuery;
  String get selectedCategoryTitle => _selectedCategoryTitle;
  String get selectedSubCategoryTitle => _selectedSubCategoryTitle;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String title) {
    if (_selectedCategoryTitle == title) {
      _selectedCategoryTitle = 'All';
    } else {
      _selectedCategoryTitle = title;
    }
    notifyListeners();
  }

  void selectSubCategory(String title) {
    if (_selectedSubCategoryTitle == title) {
      _selectedSubCategoryTitle = 'All';
    } else {
      _selectedSubCategoryTitle = title;
    }
    notifyListeners();
  }

  void toggleFavorite(String venueId) {
    final index = _venues.indexWhere((v) => v.id == venueId);
    if (index != -1) {
      _venues[index] = _venues[index].copyWith(
        isFavorite: !_venues[index].isFavorite,
      );
      notifyListeners();
    }
  }
}
