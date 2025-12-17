import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepositoryImpl();

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _user != null;

  // Get remember me status
  Future<bool> getRememberMe() async {
    return await _authRepository.getRememberMe();
  }

  // Initialize authentication state
  Future<void> initialize() async {
    // Set loading state without notifying immediately to avoid build-time issues
    _isLoading = true;

    try {
      // Only check for persistent login if remember me was enabled
      final rememberMe = await _authRepository.getRememberMe();
      print('[DEBUG] Remember Me value on init: $rememberMe');
      if (rememberMe) {
        final isLoggedIn = await _authRepository.isLoggedIn();

        if (isLoggedIn) {
          // Check if session is still valid
          final sessionResponse = await _authRepository.checkSession();

          if (sessionResponse.isSuccess &&
              sessionResponse.data != null &&
              sessionResponse.data!.valid) {
            _user = sessionResponse.data!.user;
            _state = AuthState.authenticated;
          } else {
            await _authRepository.clearAuthData();
            _state = AuthState.unauthenticated;
          }
        } else {
          _state = AuthState.unauthenticated;
        }
      } else {
        // Clear any existing auth data if remember me is disabled
        await _authRepository.clearAuthData();
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize authentication: ${e.toString()}';
      _state = AuthState.error;
    } finally {
      _isLoading = false;
      // Single notification at the end to avoid multiple rebuilds
      notifyListeners();
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('[DEBUG] Remember Me value on login: $rememberMe');
      final response = await _authRepository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (response.isSuccess && response.data != null) {
        _user = response.data!.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authRepository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (response.isSuccess && response.data != null) {
        _user = response.data!.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.logout();
      _user = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
      // Still clear local state even if request fails
      _user = null;
      _setState(AuthState.unauthenticated);
    } finally {
      _setLoading(false);
    }
  }

  // Request password reset
  Future<bool> requestPasswordReset({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authRepository.requestPasswordReset(email: email);

      if (response.isSuccess) {
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Password reset request failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authRepository.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      if (response.isSuccess) {
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;

    try {
      final sessionResponse = await _authRepository.checkSession();

      if (sessionResponse.isSuccess &&
          sessionResponse.data != null &&
          sessionResponse.data!.valid) {
        _user = sessionResponse.data!.user;
        notifyListeners();
      } else {
        await logout();
      }
    } catch (e) {
      _setError('Failed to refresh user data: ${e.toString()}');
    }
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Private methods
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _user != null
          ? AuthState.authenticated
          : AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
