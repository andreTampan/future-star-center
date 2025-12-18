import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://10.42.0.1:8080';
  static const String apiVersion = '/api';
  static const String authEndpoint = '$apiVersion/auth';

  // API Endpoints
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = '$authEndpoint/register';
  static const String logoutEndpoint = '$authEndpoint/logout';
  static const String sessionEndpoint = '$authEndpoint/session';
  static const String requestPasswordResetEndpoint =
      '$authEndpoint/request-password-reset';
  static const String resetPasswordEndpoint = '$authEndpoint/reset-password';

  // App Information
  static const String appName = 'Future Star Center';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String sessionKey = 'session_id';
  static const String rememberMeKey = 'remember_me';

  // Theme Colors (extracted from logo)
  static const Color primaryColor = Color(0xFF2E7D8A); // Teal blue from logo
  static const Color primaryDarkColor = Color(0xFF1E5A63);
  static const Color primaryLightColor = Color(0xFF4A9BAB);

  static const Color secondaryColor = Color(
    0xFFF39C12,
  ); // Orange/gold accent from logo
  static const Color secondaryDarkColor = Color(0xFFE67E22);
  static const Color secondaryLightColor = Color(0xFFF5B041);

  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF27AE60);
  static const Color warningColor = Color(0xFFF39C12);

  // Text Colors
  static const Color primaryTextColor = Color(0xFF2C3E50);
  static const Color secondaryTextColor = Color(0xFF7F8C8D);
  static const Color lightTextColor = Color(0xFFBDC3C7);
  static const Color whiteTextColor = Color(0xFFFFFFFF);

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  static const double defaultBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double cardBorderRadius = 12.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxEmailLength = 254;
  static const int maxNameLength = 100;

  // Network
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
