import 'package:http/http.dart' as http;
import 'package:rentguard/utils/constants.dart';
import 'dart:convert';

class ApiService {
  static Future<http.Response> postRequest(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.post(url,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getRequest(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.get(url, headers: {'Content-Type': 'application/json'});
  }
}
