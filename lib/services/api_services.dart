import 'package:http/http.dart' as http;
import 'package:rentguard/utils/constants.dart';
import 'dart:convert';
import 'package:rentguard/models/property.dart';

class ApiService {
  static Future<http.Response> postRequest(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/users/$endpoint');
    return await http.post(url,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl/users/$endpoint');
    return await http.get(url, headers: {'Content-Type': 'application/json'});
  }

  static Future<List<Property>> fetchProperties() async {
    final url = Uri.parse('$baseUrl/properties');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((property) => Property.fromJson(property))
          .toList();
    } else {
      throw Exception('Failed to load properties');
    }
  }

  static Future<String> getUserPhoneById(int ownerId) async {
    final url = Uri.parse('$baseUrl/users/$ownerId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['phone'];
    } else {
      throw Exception('Failed to load user phone');
    }
  }
}
