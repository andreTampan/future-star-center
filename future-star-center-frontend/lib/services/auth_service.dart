import '../constants/app_constants.dart';
import '../models/api_response.dart';
import '../models/auth_models.dart';
import '../models/user.dart';
import '../utils/storage_service.dart';
import 'http_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HttpService _httpService = HttpService();
  final StorageService _storageService = StorageService();

  // Login user
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final request = AuthRequest.login(email: email, password: password);

      final response = await _httpService.post<Map<String, dynamic>>(
        AppConstants.loginEndpoint,
        body: request.toJson(),
        includeAuth: false,
      );

      if (response.isSuccess && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);

        // Save remember me preference
        await _storageService.saveRememberMe(rememberMe);

        // Only save authentication data if remember me is checked
        if (rememberMe) {
          if (authResponse.token != null) {
            await _storageService.saveToken(authResponse.token!);
          }

          if (authResponse.sessionId != null) {
            await _storageService.saveSessionId(authResponse.sessionId!);
          }

          if (authResponse.user != null) {
            await _storageService.saveUser(authResponse.user!);
          }
        }

        return ApiResponse.success(
          message: response.message,
          data: authResponse,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: response.message,
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Login failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Register user
  Future<ApiResponse<AuthResponse>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final request = AuthRequest.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      final response = await _httpService.post<Map<String, dynamic>>(
        AppConstants.registerEndpoint,
        body: request.toJson(),
        includeAuth: false,
      );

      if (response.isSuccess && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data!);

        // Save authentication data
        if (authResponse.token != null) {
          await _storageService.saveToken(authResponse.token!);
        }

        if (authResponse.sessionId != null) {
          await _storageService.saveSessionId(authResponse.sessionId!);
        }

        if (authResponse.user != null) {
          await _storageService.saveUser(authResponse.user!);
        }

        return ApiResponse.success(
          message: response.message,
          data: authResponse,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: response.message,
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Registration failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Logout user
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _httpService.post<Map<String, dynamic>>(
        AppConstants.logoutEndpoint,
        includeAuth: true,
      );

      // Clear local authentication data regardless of server response
      await _storageService.clearAuthData();
      await _storageService.removeRememberMe();

      if (response.isSuccess) {
        return ApiResponse.success(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      // Still clear local data even if request fails
      await _storageService.clearAuthData();
      await _storageService.removeRememberMe();

      return ApiResponse.error(
        message: 'Logout failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Check session validity
  Future<ApiResponse<SessionResponse>> checkSession() async {
    try {
      final response = await _httpService.get<Map<String, dynamic>>(
        AppConstants.sessionEndpoint,
        includeAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        final sessionResponse = SessionResponse.fromJson(response.data!);

        // Update user data if valid session
        if (sessionResponse.valid && sessionResponse.user != null) {
          await _storageService.saveUser(sessionResponse.user!);
        } else {
          // Clear auth data if session is invalid
          await _storageService.clearAuthData();
        }

        return ApiResponse.success(
          message: response.message,
          data: sessionResponse,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Session check failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Request password reset
  Future<ApiResponse<void>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final request = PasswordResetRequest(email: email);

      final response = await _httpService.post<Map<String, dynamic>>(
        AppConstants.requestPasswordResetEndpoint,
        body: request.toJson(),
        includeAuth: false,
      );

      if (response.isSuccess) {
        return ApiResponse.success(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Password reset request failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Reset password
  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final request = PasswordResetConfirm(
        token: token,
        newPassword: newPassword,
      );

      final response = await _httpService.post<Map<String, dynamic>>(
        AppConstants.resetPasswordEndpoint,
        body: request.toJson(),
        includeAuth: false,
      );

      if (response.isSuccess) {
        return ApiResponse.success(
          message: response.message,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Password reset failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return await _storageService.getUser();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  // Get current token
  Future<String?> getToken() async {
    return await _storageService.getToken();
  }

  // Get remember me status
  Future<bool> getRememberMe() async {
    return await _storageService.getRememberMe();
  }

  // Clear all authentication data
  Future<void> clearAuthData() async {
    await _storageService.clearAuthData();
  }
}
