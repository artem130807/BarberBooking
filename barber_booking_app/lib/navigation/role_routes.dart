class RoleRoutes {
  RoleRoutes._();

  static const int userRole = 1;
  static const int adminRole = 2;
  static const int masterRole = 3;

  static String homeRouteForRole(int? roleInterface) {
    if (roleInterface == adminRole) return '/admin_home';
    if (roleInterface == masterRole) return '/master_home';
    return '/home';
  }
}
