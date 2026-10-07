import 'user_role.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.email,
    this.password,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    this.activeTaskCount,
  });

  final String id;
  final String organizationId;
  final String name;
  final String email;
  final String? password;
  final String? avatarUrl;
  final UserRole role;
  final bool isActive;
  final int? activeTaskCount;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      organizationId: (map['organization_id'] ?? map['organizationId'] ?? '') as String,
      name: (map['name'] as String?) ?? '',
      email: (map['auth_email'] ?? map['email_display'] ?? map['email'] as String?) ?? '',
      password: map['password'] as String?,
      avatarUrl: (map['avatar_url'] ?? map['avatarUrl']) as String?,
      role: UserRole.fromDb((map['role'] as String?) ?? 'employee'),
      isActive: (map['is_active'] ?? map['isActive'] ?? true) as bool,
      activeTaskCount: _parseInt(map['active_task_count'] ?? map['activeTaskCount']),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v == null) return null;
    return int.tryParse('$v');
  }

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'email': email,
      'auth_email': email,
      'email_display': email,
      if (password != null) 'password': password,
      'avatar_url': avatarUrl,
      'role': role.dbValue,
      'is_active': isActive,
      'active_task_count': activeTaskCount,
    };
  }
}
