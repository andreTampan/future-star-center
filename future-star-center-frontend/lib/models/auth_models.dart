import 'user.dart';

class AuthRequest {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  AuthRequest({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

  Map<String, dynamic> toJson() {
    final map = {'email': email, 'password': password};

    if (firstName != null) map['first_name'] = firstName!;
    if (lastName != null) map['last_name'] = lastName!;

    return map;
  }

  factory AuthRequest.login({required String email, required String password}) {
    return AuthRequest(email: email, password: password);
  }

  factory AuthRequest.register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    return AuthRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final String? sessionId;
  final User? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.sessionId,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: (json['message'] ?? '').toString(),
      token: json['token'],
      sessionId: json['session_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'session_id': sessionId,
      'user': user?.toJson(),
    };
  }
}

class PasswordResetRequest {
  final String email;

  PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class PasswordResetConfirm {
  final String token;
  final String newPassword;

  PasswordResetConfirm({required this.token, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {'token': token, 'new_password': newPassword};
  }
}

class SessionResponse {
  final bool valid;
  final User? user;
  final String? message;

  SessionResponse({required this.valid, this.user, this.message});

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    return SessionResponse(
      valid: json['valid'] ?? false,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message']?.toString(),
    );
  }
}
