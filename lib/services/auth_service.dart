import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://www.mindwareinfotech.com/api/v1';

  // Temporary flag to bypass auth during development
  static const bool skipAuth = false; // Disabled bypass to allow real token testing

  Future<http.Response> _post(String endpoint, Map<String, dynamic> body, {bool requireAuth = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = await getToken(); // Use getToken() to leverage the bypass

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      if (requireAuth && token != null) 'Authorization': 'Bearer $token',
    };

    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<Map<String, dynamic>> login(String identifier, String password, {String? emailOtp, String role = 'employer'}) async {
    try {
      final Map<String, dynamic> body = {
        'email': identifier,
        'password': password,
        'role': role,
      };
      if (emailOtp != null) {
        body['email_otp'] = emailOtp;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({
          ...body,
          'purpose': 'auth',
        }),
      );

      print('Login Response (${response.statusCode}): ${response.body}');

      if (response.body.startsWith('{')) {
        final data = jsonDecode(response.body);
        print("LOGIN DATA: $data");

        if (response.statusCode == 200) {
          // Extract token from multiple possible locations
          String? token;
          if (data['token'] is String) token = data['token'];
          if (token == null && data['access_token'] is String) token = data['access_token'];
          
          if (token == null && data['data'] != null && data['data'] is Map) {
            final inner = data['data'] as Map;
            if (inner['token'] is String) token = inner['token'];
            if (token == null && inner['access_token'] is String) token = inner['access_token'];
          }
          
          if (token == null && data['authorization'] != null && data['authorization'] is Map) {
            final authData = data['authorization'] as Map;
            if (authData['token'] is String) token = authData['token'];
          }

          if (token != null && token.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token);
            print("✅ TOKEN SAVED: ${token.substring(0, 10)}...");
            return {'success': true, 'data': data};
          } else {
            print("⚠️ No token found in login response");
            // If success is true but no token, we might still want to proceed if it's a multi-step login
            if (data['success'] == true || data['status'] == 'success') {
               return {'success': true, 'data': data};
            }
            return {'success': false, 'message': 'Authentication failed: No token received'};
          }
        } else {
          final errorMessage = data['message'] ?? 'Login failed: ${response.statusCode}';
          
          // Fallback to web-style login if API login fails with OTP error
          if (errorMessage.toLowerCase().contains('otp') || errorMessage.toLowerCase().contains('expired')) {
            print('API Login failed with OTP error, trying web-style fallback...');
            final webResponse = await http.post(
              Uri.parse('https://www.mindwareinfotech.com/login'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
              },
              body: jsonEncode({
                ...body,
                'purpose': 'auth',
              }),
            );
            
            print('Web-style Login Status: ${webResponse.statusCode}');
            print('Web-style Login Response: ${webResponse.body}');
            
            if (webResponse.body.startsWith('{')) {
              final webData = jsonDecode(webResponse.body);
              if (webResponse.statusCode == 200 || webData['success'] == true) {
                final prefs = await SharedPreferences.getInstance();
                String? token = webData['token'] ?? webData['access_token'];
                if (token == null && webData['data'] != null) {
                  token = webData['data']['token'] ?? webData['data']['access_token'];
                }
                await prefs.setString('token', token ?? '');
                return {'success': true, 'data': webData};
              }
              return {'success': false, 'message': webData['message'] ?? errorMessage};
            }
          }
          
          return {'success': false, 'message': errorMessage};
        }
      } else {
        return {'success': false, 'message': 'Server error: Invalid response format (HTML received)'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> sendEmailOtp(String email, {String purpose = 'auth', String role = 'employer'}) async {
    final Map<String, String> commonHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'User-Agent': 'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.106 Mobile Safari/537.36',
      'Origin': 'https://www.mindwareinfotech.com',
      'Referer': 'https://www.mindwareinfotech.com/',
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-email-otp'),
        headers: commonHeaders,
        body: jsonEncode({
          'email': email,
          'purpose': purpose,
          'role': role,
        }),
      );

      print('Send OTP Status: ${response.statusCode}');
      print('Send OTP Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message'] ?? 'OTP sent successfully'};
      } 
      
      if (response.statusCode == 404 || response.statusCode == 403) {
        final fallbackResponse = await http.post(
          Uri.parse('https://www.mindwareinfotech.com/auth/email/send-otp'),
          headers: commonHeaders,
          body: jsonEncode({
            'email': email,
            'purpose': purpose,
            'role': role,
          }),
        );
        
        print('Fallback OTP Status: ${fallbackResponse.statusCode}');
        print('Fallback OTP Response: ${fallbackResponse.body}');
        
        if (fallbackResponse.body.startsWith('{')) {
          final data = jsonDecode(fallbackResponse.body);
          if (fallbackResponse.statusCode == 200 || data['success'] == true) {
            return {'success': true, 'message': data['message'] ?? 'OTP sent successfully'};
          } else {
            // Handle the "session refreshed" error by suggesting a retry which might have the cookie now
            if (data['error'] != null && data['error'].contains('session was refreshed')) {
              return {'success': false, 'message': 'Session initialized. Please tap "Send OTP" again.'};
            }
            return {'success': false, 'message': data['message'] ?? data['error'] ?? 'Failed to send OTP'};
          }
        }
      }
      
      return {'success': false, 'message': 'Failed to send OTP (${response.statusCode})'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> registerEmployer({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
    required String emailOtp,
  }) async {
    try {
      final response = await _post('/register-employer', {
        'company_name': fullName,
        'phone': mobile,
        'email': email,
        'password': password,
        'email_otp': emailOtp,
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
    if (kDebugMode && skipAuth) {
      return "temp_testing_token";
    }
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
      
      // Try to return cached profile first for instant UI
      final cachedProfile = prefs.getString('user_profile');
      if (cachedProfile != null) {
        try {
          final decoded = jsonDecode(cachedProfile);
          // Return cached data but still fetch fresh in background if needed
          // For now, we return it to satisfy the immediate UI need
          return {'success': true, 'data': decoded, 'from_cache': true};
        } catch (_) {}
      }

      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};
      
      final getResponse = await http.get(
        Uri.parse('$baseUrl/employer/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (getResponse.body.startsWith('{')) {
        final data = jsonDecode(getResponse.body);
        if (getResponse.statusCode == 200) {
          final profileData = data['data'] ?? data;
          // Save to cache
          await prefs.setString('user_profile', jsonEncode(profileData));
          return {'success': true, 'data': profileData};
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
      final token = await getToken();

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
  Future<Map<String, dynamic>> reverseGeocode(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.mindwareinfotech.com/api/geo/reverse?lat=$lat&lon=$lng'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Reverse geocoding failed: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Geocoding error: $e'};
    }
  }

  Future<Map<String, dynamic>> searchLocation(String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.mindwareinfotech.com/api/geo/search?q=${Uri.encodeComponent(query)}&limit=1'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Location search failed: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Search error: $e'};
    }
  }
}
