import 'package:flutter/foundation.dart';

import '../../../core/storage/local_store.dart';
import '../data/auth_repository.dart';
import '../data/mock_auth_repository.dart';
import '../models/customer_profile.dart';

/// Holds the signed-in profile and persists only the session snapshot.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? MockAuthRepository() {
    _restoreSession();
  }

  static const String _sessionKey = 'tatito_session_v1';

  final AuthRepository _repository;
  CustomerProfile? _currentUser;
  bool _restoring = true;

  CustomerProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isRestoring => _restoring;
  bool get isCustomer => _currentUser?.role.name == 'customer';

  Future<void> _restoreSession() async {
    final raw = await LocalStore.readJson(_sessionKey);
    if (raw is Map<String, dynamic>) {
      _currentUser = CustomerProfile.fromJson(raw);
    } else if (raw is Map) {
      _currentUser = CustomerProfile.fromJson(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    _restoring = false;
    notifyListeners();
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final profile = await _repository.signIn(
        email: email,
        password: password,
      );
      _currentUser = profile;
      await LocalStore.writeJson(_sessionKey, profile.toJson());
      notifyListeners();
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'Unable to sign in right now. Please try again.';
    }
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final profile = await _repository.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      _currentUser = profile;
      await LocalStore.writeJson(_sessionKey, profile.toJson());
      notifyListeners();
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'Unable to create the account right now. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _currentUser = null;
    await LocalStore.remove(_sessionKey);
    notifyListeners();
  }

  Future<String?> requestPasswordReset(String email) async {
    try {
      return await _repository.requestPasswordReset(email);
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'Unable to request a reset code right now.';
    }
  }

  Future<String?> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      await _repository.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'Unable to reset the password right now.';
    }
  }
}
