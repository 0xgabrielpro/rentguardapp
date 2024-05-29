import 'package:http/http.dart' as http;
import 'package:rentguard/utils/constants.dart';
import 'dart:convert';
import 'package:rentguard/models/property.dart';

class ApiService {
  static Future<http.Response> postRequest(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/users/$endpoint');
    try {
      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      return response;
    } catch (e) {
      throw Exception('Failed to post request: $e');
    }
  }

  static Future<http.Response> getRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl/users/$endpoint');
    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      return response;
    } catch (e) {
      throw Exception('Failed to get request: $e');
    }
  }

  static Future<List<Property>> fetchProperties() async {
    final url = Uri.parse('$baseUrl/properties');
    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((property) => Property.fromJson(property))
            .toList();
      } else {
        throw Exception('Failed to load properties: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching properties: $e');
      throw Exception('Failed to load properties: $e');
    }
  }

  static Future<String> getUserPhoneById(int ownerId) async {
    final url = Uri.parse('$baseUrl/users/$ownerId');
    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['phone'];
      } else {
        throw Exception('Failed to load user phone: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load user phone: $e');
    }
  }

  static Future<http.Response> resetPassword(
      String token, String currentPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/users/reset-password');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );
  }

  static Future<http.Response> forgotPassword(
      String email, String newPassword) async {
    final url = Uri.parse('$baseUrl/users/forgot-password');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'newPassword': newPassword,
      }),
    );
  }
}
