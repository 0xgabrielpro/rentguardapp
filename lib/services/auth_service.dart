import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:rentguard/services/api_services.dart';

class AuthService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences once
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> register(String username, String email, String phone,
      String password, String gender) async {
    final response = await ApiService.postRequest('register', {
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
      'gender': gender, // Ensure gender is included in the request body
    });

    return response.statusCode == 201;
  }

  static Future<bool> login(String email, String password) async {
    final response = await ApiService.postRequest('login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final role =
          data['role']; // Assuming the role is also returned in the response

      // Save token and role to SharedPreferences
      if (_prefs == null) {
        await init();
      }
      await _prefs!.setString('token', token);
      await _prefs!.setString('role', role);

      return true;
    } else {
      return false;
    }
  }

  static Future<void> logout() async {
    // Remove token and role from SharedPreferences upon logout
    if (_prefs == null) {
      await init();
    }
    await _prefs!.remove('token');
    await _prefs!.remove('role');
  }

  // Method to get the stored token
  static Future<String?> getToken() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!.getString('token');
  }

  // Method to get the stored user role
  static Future<String?> getRole() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!.getString('role');
  }
}
