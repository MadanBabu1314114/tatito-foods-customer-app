/// Roles supported by the shared Tatito account model.
enum UserRole { customer, admin, delivery }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.admin:
        return 'Admin';
      case UserRole.delivery:
        return 'Delivery Partner';
    }
  }

  static UserRole fromStorage(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'delivery':
        return UserRole.delivery;
      default:
        return UserRole.customer;
    }
  }
}
