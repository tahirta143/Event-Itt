import 'package:flutter/material.dart';
import 'admin_auth_provider.dart';
import 'vendor_auth_provider.dart';
import 'customer_auth_provider.dart';

/// Enum representing which role is currently active.
enum UserRole { none, admin, vendor, customer }

/// Unified auth coordinator.
///
/// This provider tracks which role is currently logged in and provides a single
/// source of truth for the app's authentication state.
///
/// Role-specific business logic (login, token management) stays in:
///   - [AdminAuthProvider]
///   - [VendorAuthProvider]
///   - [CustomerAuthProvider]
///
/// This class is kept to maintain backwards-compatibility with existing
/// widgets that import it (e.g. CustomDrawerWidget uses AuthProvider).
class AuthProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.none;
  bool _isInitialized = false;

  UserRole get currentRole => _currentRole;
  bool get isLoggedIn => _currentRole != UserRole.none;
  bool get isInitialized => _isInitialized;

  // Legacy getters used by existing widgets (CustomDrawerWidget, etc.)
  // These are filled by the active role's provider.
  String _userName = '';
  String _userEmail = '';

  String get userName => _userName;
  String get userEmail => _userEmail;

  /// Must be called from [main.dart] after all role providers are ready.
  /// Checks stored sessions and sets the active role.
  Future<void> initializeRole({
    required AdminAuthProvider adminAuth,
    required VendorAuthProvider vendorAuth,
    required CustomerAuthProvider customerAuth,
  }) async {
    // Restore all sessions
    await Future.wait([
      adminAuth.restoreSession(),
      vendorAuth.restoreSession(),
      customerAuth.restoreSession(),
    ]);

    // Determine which role to activate (priority: admin > vendor > customer)
    if (adminAuth.isAuthenticated) {
      _setRole(UserRole.admin, adminAuth.userName, adminAuth.userEmail);
    } else if (vendorAuth.isAuthenticated) {
      _setRole(UserRole.vendor, vendorAuth.vendorName, vendorAuth.vendorEmail);
    } else if (customerAuth.isAuthenticated) {
      _setRole(UserRole.customer, customerAuth.customerName, customerAuth.customerEmail);
    } else {
      _currentRole = UserRole.none;
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Call after a successful role-specific login.
  void setActiveRole(UserRole role, String name, String email) {
    _setRole(role, name, email);
    notifyListeners();
  }

  void _setRole(UserRole role, String name, String email) {
    _currentRole = role;
    _userName = name;
    _userEmail = email;
  }

  /// Clears the active role (call after role-specific logout).
  void clearRole() {
    _currentRole = UserRole.none;
    _userName = '';
    _userEmail = '';
    notifyListeners();
  }

  /// Legacy login stub — kept so existing widgets don't break.
  /// Real login is done via the role-specific providers.
  void login(String email, String password) {
    _userEmail = email;
    notifyListeners();
  }

  /// Legacy logout stub.
  void logout() {
    clearRole();
  }
}
