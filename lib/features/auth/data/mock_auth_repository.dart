import '../models/customer_profile.dart';
import '../models/user_role.dart';
import 'auth_repository.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _MockAccount {
  _MockAccount({
    required this.profile,
    required this.password,
  });

  final CustomerProfile profile;
  String password;
}

/// Demo-only authentication. Accounts live in memory; only the signed-in
/// profile is persisted by [AuthProvider]. Replace with an API repository later.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    _accounts.addAll([
      _MockAccount(
        profile: const CustomerProfile(
          id: 'customer-demo',
          name: 'Demo Customer',
          email: 'customer@tatitofoods.test',
          phone: '+91 98765 43210',
          role: UserRole.customer,
        ),
        password: 'Customer@12345',
      ),
      _MockAccount(
        profile: const CustomerProfile(
          id: 'admin-demo',
          name: 'Store Admin',
          email: 'admin@tatitofoods.test',
          phone: '+91 90000 00001',
          role: UserRole.admin,
        ),
        password: 'Admin@12345',
      ),
      _MockAccount(
        profile: const CustomerProfile(
          id: 'delivery-demo',
          name: 'Delivery Partner',
          email: 'delivery@tatitofoods.test',
          phone: '+91 90000 00002',
          role: UserRole.delivery,
        ),
        password: 'Delivery@12345',
      ),
    ]);
  }

  static const int maxFailedAttempts = 5;
  static const Duration lockDuration = Duration(minutes: 5);

  final List<_MockAccount> _accounts = [];
  final Map<String, int> _failedAttempts = {};
  final Map<String, DateTime> _lockedUntil = {};
  final Map<String, String> _resetTokens = {};
  CustomerProfile? _currentProfile;

  @override
  CustomerProfile? get currentProfile => _currentProfile;

  @override
  Future<CustomerProfile> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final locked = _lockedUntil[normalizedEmail];
    if (locked != null && DateTime.now().isBefore(locked)) {
      final minutes = locked.difference(DateTime.now()).inMinutes + 1;
      throw AuthException(
        'Too many wrong attempts. Try again in about $minutes minute(s).',
      );
    }

    final account = _findAccount(normalizedEmail);
    if (account == null || account.password != password) {
      final attempts = (_failedAttempts[normalizedEmail] ?? 0) + 1;
      _failedAttempts[normalizedEmail] = attempts;
      if (attempts >= maxFailedAttempts) {
        _lockedUntil[normalizedEmail] = DateTime.now().add(lockDuration);
        _failedAttempts[normalizedEmail] = 0;
        throw const AuthException(
          'Too many wrong attempts. Account temporarily locked for 5 minutes.',
        );
      }
      final remaining = maxFailedAttempts - attempts;
      throw AuthException(
        'Incorrect email or password. $remaining attempt(s) remaining.',
      );
    }

    _failedAttempts.remove(normalizedEmail);
    _lockedUntil.remove(normalizedEmail);
    _currentProfile = account.profile;
    return account.profile;
  }

  @override
  Future<CustomerProfile> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_findAccount(normalizedEmail) != null) {
      throw const AuthException('An account with this email already exists.');
    }
    final profile = CustomerProfile(
      id: 'customer-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      role: UserRole.customer,
    );
    _accounts.add(_MockAccount(profile: profile, password: password));
    _currentProfile = profile;
    return profile;
  }

  @override
  Future<void> signOut() async {
    _currentProfile = null;
  }

  @override
  Future<String> requestPasswordReset(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_findAccount(normalizedEmail) == null) {
      throw const AuthException('No account found with this email.');
    }
    final token = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
        .toString();
    _resetTokens[normalizedEmail] = token;
    return token;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final expected = _resetTokens[normalizedEmail];
    if (expected == null || expected != token.trim()) {
      throw const AuthException('Invalid or expired reset code.');
    }
    final account = _findAccount(normalizedEmail);
    if (account == null) {
      throw const AuthException('No account found with this email.');
    }
    account.password = newPassword;
    _resetTokens.remove(normalizedEmail);
    _failedAttempts.remove(normalizedEmail);
    _lockedUntil.remove(normalizedEmail);
  }

  _MockAccount? _findAccount(String email) {
    for (final account in _accounts) {
      if (account.profile.email.toLowerCase() == email) return account;
    }
    return null;
  }
}
