import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:rentguard/services/api_services.dart';

class AuthService {
  static SharedPreferences? _prefs;

  static Future<bool> register(String username, String email, String phone,
      String password, String gender) async {
    final response = await ApiService.postRequest('register', {
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
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

      // Save token to SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      await _prefs!.setString('token', token);

      return true;
    } else {
      return false;
    }
  }

  static Future<void> logout() async {
    // Remove token from SharedPreferences upon logout
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.remove('token');
  }
}
