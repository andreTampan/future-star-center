import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import '../utils/storage_service.dart';

enum HttpMethod { get, post, put, delete, patch }

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  late http.Client _client;
  final StorageService _storageService = StorageService();

  void initialize() {
    _client = http.Client();
  }

  void dispose() {
    _client.close();
  }

  Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
    Map<String, String>? customHeaders,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _storageService.getToken();
      final sessionId = await _storageService.getSessionId();

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      if (sessionId != null) {
        headers['X-Session-ID'] = sessionId;
      }
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required HttpMethod method,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    Map<String, String>? customHeaders,
    bool includeAuth = true,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = await _getHeaders(
        includeAuth: includeAuth,
        customHeaders: customHeaders,
      );

      http.Response response;
      final jsonBody = body != null ? jsonEncode(body) : null;

      switch (method) {
        case HttpMethod.get:
          response = await _client
              .get(uri, headers: headers)
              .timeout(
                const Duration(milliseconds: AppConstants.connectionTimeout),
              );
          break;
        case HttpMethod.post:
          response = await _client
              .post(uri, headers: headers, body: jsonBody)
              .timeout(
                const Duration(milliseconds: AppConstants.connectionTimeout),
              );
          break;
        case HttpMethod.put:
          response = await _client
              .put(uri, headers: headers, body: jsonBody)
              .timeout(
                const Duration(milliseconds: AppConstants.connectionTimeout),
              );
          break;
        case HttpMethod.delete:
          response = await _client
              .delete(uri, headers: headers)
              .timeout(
                const Duration(milliseconds: AppConstants.connectionTimeout),
              );
          break;
        case HttpMethod.patch:
          response = await _client
              .patch(uri, headers: headers, body: jsonBody)
              .timeout(
                const Duration(milliseconds: AppConstants.connectionTimeout),
              );
          break;
      }

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on HttpException {
      return ApiResponse.error(message: 'HTTP error occurred', statusCode: 0);
    } on FormatException {
      return ApiResponse.error(
        message: 'Invalid response format',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  Uri _buildUri(String endpoint, Map<String, String>? queryParameters) {
    final baseUri = Uri.parse('${AppConstants.baseUrl}$endpoint');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return baseUri.replace(queryParameters: queryParameters);
    }

    return baseUri;
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    try {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        T? data;
        if (fromJson != null && jsonData['data'] != null) {
          data = fromJson(jsonData['data']);
        } else if (jsonData['data'] != null) {
          data = jsonData['data'] as T;
        }

        return ApiResponse.success(
          message: jsonData['message'] ?? 'Success',
          data: data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          message: jsonData['message'] ?? 'Request failed',
          errors: jsonData['errors'],
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to parse response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  // Convenience methods
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? customHeaders,
    bool includeAuth = true,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.get,
      queryParameters: queryParameters,
      customHeaders: customHeaders,
      includeAuth: includeAuth,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
    bool includeAuth = true,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.post,
      body: body,
      customHeaders: customHeaders,
      includeAuth: includeAuth,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
    bool includeAuth = true,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.put,
      body: body,
      customHeaders: customHeaders,
      includeAuth: includeAuth,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? customHeaders,
    bool includeAuth = true,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.delete,
      queryParameters: queryParameters,
      customHeaders: customHeaders,
      includeAuth: includeAuth,
      fromJson: fromJson,
    );
  }
}
