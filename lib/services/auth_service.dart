// import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rentguard/services/api_services.dart';

class AuthService {
  static Future<bool> register(String username, String email, String phone,
      String password, String gender) async {
    final response = await ApiService.postRequest('register', {
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
      'gender': gender,
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
      print(data);
      // Save the token
      return true;
    } else {
      return false;
    }
  }

  static Future<void> logout() async {
    // Implement logout functionality
  }
}
