enum UserRole {
  founder,
  admin,
  employee,
  intern;

  static UserRole fromDb(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.employee,
    );
  }

  String get dbValue => name;

  String get label {
    switch (this) {
      case UserRole.founder:
        return 'Founder';
      case UserRole.admin:
        return 'Admin';
      case UserRole.employee:
        return 'Employee';
      case UserRole.intern:
        return 'Intern';
    }
  }

  bool get canAccessAdmin => this == UserRole.founder || this == UserRole.admin;
  bool get canManageUsers => canAccessAdmin;
  bool get canManageOrg => this == UserRole.founder || this == UserRole.admin;
  bool get canChangeAdminRoles => this == UserRole.admin;
}
