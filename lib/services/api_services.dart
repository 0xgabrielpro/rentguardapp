import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:rentguard/models/agrequest.dart';
import 'package:rentguard/models/property.dart';
import 'package:rentguard/utils/constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';

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

  static Future<void> createProperty(
    String location,
    double price,
    String description,
    XFile? image,
    int ownerId,
  ) async {
    var uri = Uri.parse('$baseUrl/properties/upload');
    var request = http.MultipartRequest('POST', uri);
    request.fields['location'] = location;
    request.fields['price'] = price.toString();
    request.fields['description'] = description;
    request.fields['ownerId'] = ownerId.toString();

    if (image != null) {
      if (kIsWeb) {
        var imageBytes = await image.readAsBytes();
        var multiPartFile = http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: image.name,
        );
        request.files.add(multiPartFile);
      } else {
        var multiPartFile = await http.MultipartFile.fromPath(
          'image',
          image.path,
        );
        request.files.add(multiPartFile);
      }
    }

    var response = await request.send();
    if (response.statusCode == 201) {
      print('Property created successfully');
    } else {
      throw Exception('Failed to create property: ${response.reasonPhrase}');
    }
  }

  static Future<void> updateProperty(
  int id,
  String location,
  double price,
  String description,
  XFile? image,
  int ownerId,
) async {
  var uri = Uri.parse('$baseUrl/properties/$id');
  var request = http.MultipartRequest('POST', uri);

  request.fields['location'] = location;
  request.fields['price'] = price.toString();
  request.fields['description'] = description;
  request.fields['ownerId'] = ownerId.toString();

  if (image != null) {
    if (kIsWeb) {
      var imageBytes = await image.readAsBytes();
      var multiPartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: image.name,
      );
      request.files.add(multiPartFile);
    } else {
      var multiPartFile = await http.MultipartFile.fromPath(
        'image',
        image.path,
      );
      request.files.add(multiPartFile);
    }
  }

  print('Request fields: ${request.fields}');
  if (request.files.isNotEmpty) {
    print('Request files: ${request.files.first.filename}');
  } else {
    print('No image file attached');
  }

  try {
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print('Property updated successfully');
    } else {
      print('Failed to update property: ${response.reasonPhrase}');
      print('Response body: $responseBody');
      throw Exception('Failed to update property: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Exception during updateProperty: $e');
    throw Exception('Failed to update property: $e');
  }
}


  static Future<void> deleteProperty(int id) async {
    final url = Uri.parse('$baseUrl/properties/$id');
    try {
      final response =
          await http.delete(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode != 200) {
        throw Exception('Failed to delete property');
      }
    } catch (e) {
      print('Error deleting property: $e');
      throw Exception('Failed to delete property: $e');
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

  static Future<Map<String, dynamic>> getUserById(int userId) async {
    final url = Uri.parse('$baseUrl/users/$userId');
    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  static Future<bool> updateUserProfile(
      int id, String username, String email, String phone) async {
    final url = Uri.parse('$baseUrl/users/update-profile/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final errorMessage = json.decode(response.body)['message'];
        throw Exception('Failed to update user profile: $errorMessage');
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  static Future<http.Response> resetPassword(
      String email, String newPassword) async {
    final url = Uri.parse('$baseUrl/users/reset-password');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
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

  static Future<bool> sendAgentRequest(int userId, String agencyName,
      String experience, String contactNumber, String email) async {
    final url = Uri.parse('$baseUrl/users/agent_request');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'agent_name': agencyName,
        'experience': experience,
        'contact_number': contactNumber,
        'email': email,
      }),
    );

    return response.statusCode == 201;
  }

  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    final url = Uri.parse('$baseUrl/admin/users');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  static Future<bool> createUser(String username, String email, String phone,
      String password, String role) async {
    final url = Uri.parse('$baseUrl/users/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      }),
    );

    return response.statusCode == 201;
  }

  static Future<bool> updateUser(int id, String username, String email,
      String phone, String password, String role) async {
    final url = Uri.parse('$baseUrl/admin/users/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': id,
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteUser(int id) async {
    final url = Uri.parse('$baseUrl/admin/users/$id');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }

  static Future<List<Property>> fetchPropertiesByOwnerId(int ownerId) async {
    final url = Uri.parse('$baseUrl/properties/owner/$ownerId');
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

  static Future<List<AgentRequest>> fetchAgentRequests() async {
    final url = Uri.parse('$baseUrl/admin/requests');
    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((request) => AgentRequest.fromJson(request))
            .toList();
      } else {
        throw Exception(
            'Failed to load agent requests: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agent requests: $e');
      throw Exception('Failed to load agent requests: $e');
    }
  }

  static Future<void> deleteAgentRequest(int requestId) async {
    final url = Uri.parse('$baseUrl/admin/requests/$requestId');
    try {
      final response =
          await http.delete(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete agent request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting agent request: $e');
      throw Exception('Failed to delete agent request: $e');
    }
  }

  static Future<void> makeUserOwner(int userId) async {
    final url = Uri.parse('$baseUrl/admin/users/$userId/make-owner');
    try {
      final response =
          await http.put(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 201) {
        return;
      } else {
        throw Exception('Failed to make user owner: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to make user owner: $e');
    }
  }
}
