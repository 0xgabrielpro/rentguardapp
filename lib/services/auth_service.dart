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
      final id = data['id'];
      final email = data['email'];

      if (token != null && role != null && id != null) {
        await _prefs!.setString('token', token);
        await _prefs!.setString('role', role);
        await _prefs!.setInt('id', id);
        await _prefs!.setString('enail', email);
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
    await _prefs!.remove('id');
    await _prefs!.remove('email');
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

  static Future<int?> getId() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!.getInt('id');
  }

  static Future<String?> getEmail() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!.getString('email');
  }

  // static Future<String> getUserProfile() async {
  //   if (_prefs == null) {
  //     await init();
  //   }

  //   final int? userId = await getId();
  //   if (userId == null) {
  //     throw Exception('User ID not found');
  //   }

  //   final response = await ApiService.getUserById(userId);

  //   final Map<String, dynamic> userData = jsonDecode(response.body);
  //   return UserProfile.fromJson(userData);
  // }

  static Future<bool> updateUserProfile(
      int id, String username, String email, String phone) async {
    try {
      final response = await ApiService.updateUserProfile(
        id,
        username,
        email,
        phone,
      );
      if (response) {
        return true;
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
}
