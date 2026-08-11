import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/admin_auth_provider.dart';

/// Conditionally renders [child] only if the logged-in admin has [permission].
///
/// If the admin does NOT have the permission, renders [fallback] (default: empty).
///
/// Example usage:
/// ```dart
/// PermissionGuard(
///   permission: 'bookings.delete',
///   child: IconButton(icon: Icon(Icons.delete), onPressed: _delete),
/// )
/// ```
class PermissionGuard extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget fallback;

  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    final adminAuth = context.watch<AdminAuthProvider>();
    if (adminAuth.hasPermission(permission)) {
      return child;
    }
    return fallback;
  }
}
