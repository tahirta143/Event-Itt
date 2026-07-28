import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = 'Sophia & Alexander';
  String _userEmail = 'wedding.planner@venuevibe.com';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;

  void login(String email, String password) {
    _isLoggedIn = true;
    _userEmail = email;
    notifyListeners();
  }

  void signUp(String name, String email, String password) {
    _isLoggedIn = true;
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
