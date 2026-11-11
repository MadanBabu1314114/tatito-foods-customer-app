import '../models/customer_profile.dart';

/// Contract kept intentionally small so a real API repository can replace the
/// mock implementation later without changing screens or providers.
abstract class AuthRepository {
  CustomerProfile? get currentProfile;

  Future<CustomerProfile> signIn({
    required String email,
    required String password,
  });

  Future<CustomerProfile> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> signOut();

  Future<String> requestPasswordReset(String email);

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });
}
