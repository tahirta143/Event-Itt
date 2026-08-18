/// Represents an admin/staff user returned by POST /api/auth/login
/// and GET /api/auth/me.
class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> permissions;

  const AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    // permissions can arrive as List<dynamic> or Map<String, bool>
    List<String> perms = [];
    final raw = json['permissions'];
    if (raw is List) {
      perms = raw.map((e) => e.toString()).toList();
    } else if (raw is Map) {
      perms = raw.entries
          .where((e) => e.value == true)
          .map((e) => e.key.toString())
          .toList();
    }

    return AdminUserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      permissions: perms,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'permissions': permissions,
      };

  /// Mirrors the shared/permissions/matrix.cjs grant logic.
  ///
  /// Returns true if:
  ///  - 'admin' or 'superadmin' is in permissions (superuser bypass)
  ///  - [key] is in permissions exactly
  ///  - [key] is a module key and any of its granular keys are present
  bool hasPermission(String key) {
    // Superuser bypass
    if (permissions.contains('admin') || permissions.contains('superadmin')) {
      return true;
    }
    // Exact match
    if (permissions.contains(key)) return true;
    // Module key → check if any granular key from that module is held
    final modulePrefix = '$key.';
    if (permissions.any((p) => p.startsWith(modulePrefix))) return true;
    return false;
  }

  AdminUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    List<String>? permissions,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
    );
  }
}
