class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int statusCode;

  ApiResponse({
    required this.success,
    required String message,
    this.data,
    this.errors,
    required this.statusCode,
  }) : message = message.toString();

  factory ApiResponse.success({
    required dynamic message,
    T? data,
    int statusCode = 200,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message.toString(),
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required dynamic message,
    Map<String, dynamic>? errors,
    int statusCode = 400,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message.toString(),
      errors: errors,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: (json['message'] ?? '').toString(),
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      errors: json['errors'],
      statusCode: json['status_code'] ?? 200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'status_code': statusCode,
    };
  }

  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
  bool get isError => !success || statusCode >= 400;

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}
