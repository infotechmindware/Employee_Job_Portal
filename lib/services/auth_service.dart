import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://mindwareinfotech.com/api/v1';

  Future<http.Response> _post(String endpoint, Map<String, dynamic> body, {bool requireAuth = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (requireAuth && token != null) 'Authorization': 'Bearer $token',
    };

    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await _post('/login', {
        'email': identifier,
        'password': password,
      });

      print('Login Response: ${response.body}');

      if (response.body.startsWith('{')) {
        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          final token = data['data'] != null ? data['data']['token'] : data['token'];
          await prefs.setString('token', token ?? '');
          return {'success': true, 'data': data};
        } else {
          return {'success': false, 'message': data['message'] ?? 'Login failed: ${response.statusCode}'};
        }
      } else {
        return {'success': false, 'message': 'Server error: Invalid response format (HTML received)'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> registerEmployer({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _post('/register-employer', {
        'company_name': fullName,
        'phone': mobile,
        'email': email,
        'password': password,
      });

      print('Register Response: ${response.body}');

      if (response.body.startsWith('{')) {
        final data = jsonDecode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return {'success': true, 'message': data['message'] ?? 'Registration successful'};
        } else {
          return {'success': false, 'message': data['message'] ?? 'Registration failed: ${response.statusCode}'};
        }
      } else {
        return {'success': false, 'message': 'Server error: Invalid response format (HTML received)'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _post('/forgot-password', {'email': email});
      
      print("Forgot Password Status: ${response.statusCode}");
      print("Forgot Password Body: ${response.body}");

      if (response.body.startsWith('{')) {
        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          return {'success': true, 'message': data['message'] ?? 'Reset link sent'};
        } else {
          return {'success': false, 'message': data['message'] ?? 'Failed to send reset link'};
        }
      } else {
        return {'success': false, 'message': '❌ API URL galat hai ya redirect ho raha hai'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _post('/logout', {}, requireAuth: true);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        return {'success': true};
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        return {'success': true, 'message': 'Logout failed on server but cleared locally'};
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      return {'success': true};
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      final getResponse = await http.get(
        Uri.parse('$baseUrl/employer/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (getResponse.body.startsWith('{')) {
        final data = jsonDecode(getResponse.body);
        if (getResponse.statusCode == 200) {
          return {'success': true, 'data': data['data'] ?? data};
        } else {
          return {'success': false, 'message': data['message'] ?? 'Failed to fetch profile'};
        }
      } else {
        return {'success': false, 'message': 'Invalid server response'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, String> fields, {Map<String, File>? files}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/employer/profile'));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll(fields);

      if (files != null) {
        for (var entry in files.entries) {
          if (entry.value.existsSync()) {
            request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value.path));
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.body.startsWith('{')) {
        final data = jsonDecode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return {'success': true, 'message': data['message'] ?? 'Profile updated successfully'};
        } else {
          return {'success': false, 'message': data['message'] ?? 'Update failed'};
        }
      } else {
        return {'success': false, 'message': 'Invalid server response'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
