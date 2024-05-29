import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:rentguard/services/api_services.dart';

class AuthService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> register(
      String username, String email, String phone, String password) async {
    if (_prefs == null) {
      await init();
    }

    final response = await ApiService.postRequest('register', {
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
    });

    return response.statusCode == 201;
  }

  static Future<bool> login(String email, String password) async {
    if (_prefs == null) {
      await init();
    }

    final response = await ApiService.postRequest('login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final role = data['role'];

      if (token != null && role != null) {
        await _prefs!.setString('token', token);
        await _prefs!.setString('role', role);
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<void> logout() async {
    if (_prefs == null) {
      await init();
    }
    await _prefs!.remove('token');
    await _prefs!.remove('role');
  }

  static Future<String?> getToken() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!.getString('token');
  }

  static Future<String?> getRole() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!.getString('role');
  }
}
