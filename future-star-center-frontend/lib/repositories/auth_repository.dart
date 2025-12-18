import '../models/api_response.dart';
import '../models/auth_models.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

abstract class AuthRepository {
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<ApiResponse<AuthResponse>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<ApiResponse<void>> logout();

  Future<ApiResponse<SessionResponse>> checkSession();

  Future<ApiResponse<void>> requestPasswordReset({required String email});

  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<String?> getToken();
  Future<bool> getRememberMe();
  Future<void> clearAuthData();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({AuthService? authService})
    : _authService = authService ?? AuthService();

  @override
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    return await _authService.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }

  @override
  Future<ApiResponse<AuthResponse>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    return await _authService.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }

  @override
  Future<ApiResponse<void>> logout() async {
    return await _authService.logout();
  }

  @override
  Future<ApiResponse<SessionResponse>> checkSession() async {
    return await _authService.checkSession();
  }

  @override
  Future<ApiResponse<void>> requestPasswordReset({
    required String email,
  }) async {
    return await _authService.requestPasswordReset(email: email);
  }

  @override
  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return await _authService.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  @override
  Future<String?> getToken() async {
    return await _authService.getToken();
  }

  @override
  Future<bool> getRememberMe() async {
    return await _authService.getRememberMe();
  }

  @override
  Future<void> clearAuthData() async {
    await _authService.clearAuthData();
  }
}
