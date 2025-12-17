import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception(
        'StorageService not initialized. Call initialize() first.',
      );
    }
    return _prefs!;
  }

  // Token management
  Future<bool> saveToken(String token) async {
    return await _preferences.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    return _preferences.getString(AppConstants.tokenKey);
  }

  Future<bool> removeToken() async {
    return await _preferences.remove(AppConstants.tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Session management
  Future<bool> saveSessionId(String sessionId) async {
    return await _preferences.setString(AppConstants.sessionKey, sessionId);
  }

  Future<String?> getSessionId() async {
    return _preferences.getString(AppConstants.sessionKey);
  }

  Future<bool> removeSessionId() async {
    return await _preferences.remove(AppConstants.sessionKey);
  }

  Future<bool> hasSessionId() async {
    final sessionId = await getSessionId();
    return sessionId != null && sessionId.isNotEmpty;
  }

  // User management
  Future<bool> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    return await _preferences.setString(AppConstants.userKey, userJson);
  }

  Future<User?> getUser() async {
    final userJson = _preferences.getString(AppConstants.userKey);
    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      // If there's an error parsing the user data, remove it
      await removeUser();
      return null;
    }
  }

  Future<bool> removeUser() async {
    return await _preferences.remove(AppConstants.userKey);
  }

  Future<bool> hasUser() async {
    final user = await getUser();
    return user != null;
  }

  // Authentication state
  Future<bool> isLoggedIn() async {
    return await hasToken() && await hasUser();
  }

  // Remember me functionality
  Future<bool> saveRememberMe(bool remember) async {
    return await _preferences.setBool(AppConstants.rememberMeKey, remember);
  }

  Future<bool> getRememberMe() async {
    return _preferences.getBool(AppConstants.rememberMeKey) ?? false;
  }

  Future<bool> removeRememberMe() async {
    return await _preferences.remove(AppConstants.rememberMeKey);
  }

  // Clear all authentication data
  Future<bool> clearAuthData() async {
    final results = await Future.wait([
      removeToken(),
      removeSessionId(),
      removeUser(),
      // Do NOT remove rememberMe here; only remove on explicit logout
    ]);

    return results.every((result) => result);
  }

  // Generic storage methods
  Future<bool> setString(String key, String value) async {
    return await _preferences.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _preferences.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _preferences.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _preferences.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _preferences.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return _preferences.getInt(key);
  }

  Future<bool> setDouble(String key, double value) async {
    return await _preferences.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    return _preferences.getDouble(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    return _preferences.getStringList(key);
  }

  Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }

  Future<bool> containsKey(String key) async {
    return _preferences.containsKey(key);
  }

  Future<bool> clear() async {
    return await _preferences.clear();
  }

  Set<String> getKeys() {
    return _preferences.getKeys();
  }
}
